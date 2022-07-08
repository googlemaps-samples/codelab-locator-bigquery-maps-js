locals {
  bq_project_id="bigquery-public-data"
  dataset_id="census_bureau_usa"
  table_id="population_by_zip_2010"
  
}
/******************************************
1. Project Services Configuration
 *****************************************/
module "activate_service_apis" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  project_id                  = var.project_id
  enable_apis                 = true

  activate_apis = [
    "orgpolicy.googleapis.com",
    "compute.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com"
  ]

  disable_services_on_destroy = false
  
}

resource "time_sleep" "sleep_after_activate_service_apis" {
  create_duration = "60s"

  depends_on = [
    module.activate_service_apis
  ]
}

/******************************************
2. Project-scoped Org Policy Relaxing
*****************************************/

module "org_policy_allow_ingress_settings" {
  source      = "terraform-google-modules/org-policy/google"
  policy_for  = "project"
  project_id  = var.project_id
  constraint  = "constraints/cloudfunctions.allowedIngressSettings"
  policy_type = "list"
  enforce     = false
  allow= ["IngressSettings.ALLOW_ALL"]
  depends_on = [
    time_sleep.sleep_after_activate_service_apis
  ]
}

module "org_policy_allow_domain_membership" {
  source      = "terraform-google-modules/org-policy/google"
  policy_for  = "project"
  project_id  = var.project_id
  constraint  = "constraints/iam.allowedPolicyMemberDomains"
  policy_type = "list"
  enforce     = false
  depends_on = [
    time_sleep.sleep_after_activate_service_apis
  ]
}

/******************************************
5. Create cloud functions
 *****************************************/
resource "google_storage_bucket" "function_bucket" {
    name     = "${var.project_id}-gmp-bq-function"
    location = var.region
    uniform_bucket_level_access       = true
    force_destroy                     = true
}
#clean up the main.py variables
resource "null_resource" "clean_up_main_python" {
  provisioner "local-exec" {
    command = <<-EOT
    sed -i "s|PROJECT_ID|${local.bq_project_id}|g" ../src/bq-query-function/main.py  
    sed -i "s|DATASET_ID|${local.dataset_id}|g" ../src/bq-query-function/main.py 
    sed -i "s|TABLE_ID|${local.table_id}|g" ../src/bq-query-function/main.py 
    
   EOT
  }

}

data "archive_file" "bq_function_source" {
    type        = "zip"
    source_dir  = "../src/bq-query-function"
    output_path = "tmp/bq_query_function.zip"
    depends_on   = [ 
        null_resource.clean_up_main_python
    ]
}


# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "bq_function_zip" {
    source       = data.archive_file.bq_function_source.output_path
    content_type = "application/zip"

    # Append to the MD5 checksum of the files's content
    # to force the zip to be updated as soon as a change occurs
    name         = "src-${data.archive_file.bq_function_source.output_md5}.zip"
    bucket       = google_storage_bucket.function_bucket.name

    # Dependencies are automatically inferred so these lines can be deleted
    depends_on   = [
        google_storage_bucket.function_bucket,  # declared in `storage.tf`
        data.archive_file.bq_function_source
    ]
}


# Create the Cloud function triggered by a `Finalize` event on the bucket
resource "google_cloudfunctions_function" "bq_query_function" {
    name                  = "gmp-bq-function"
    runtime               = "python39"  # of course changeable

    # Get the source code of the cloud function as a Zip compression
    source_archive_bucket = google_storage_bucket.function_bucket.name
    source_archive_object = google_storage_bucket_object.bq_function_zip.name

    # Must match the function name in the cloud function `main.py` source code
    entry_point           = "bq_query_zipcode"
    
    # 
    trigger_http          = true

    # Dependencies are automatically inferred so these lines can be deleted
    depends_on            = [
        google_storage_bucket.function_bucket,  # declared in `storage.tf`
        google_storage_bucket_object.bq_function_zip
    ]
}


/******************************************
9. Cloud function SA IAM policy bindings
 *****************************************/

# Create IAM entry so all users can invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.bq_query_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_project_iam_binding" "set_storage_binding" {
  project = var.project_id
  role               = "roles/storage.admin"
  members  =  ["serviceAccount:${var.project_id}@appspot.gserviceaccount.com"]
  
}

resource "google_project_iam_binding" "set_bq_data_binding" {
  project = var.project_id
  role               = "roles/bigquery.dataEditor"
  members  =  ["serviceAccount:${var.project_id}@appspot.gserviceaccount.com"]
  
}

resource "google_project_iam_binding" "set_bq_jb_binding" {
  project = var.project_id
  role               = "roles/bigquery.jobUser"
  members  =  ["serviceAccount:${var.project_id}@appspot.gserviceaccount.com"]
  
}


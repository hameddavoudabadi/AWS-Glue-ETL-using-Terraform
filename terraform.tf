
provider "aws" {
  region = "us-west-1"
}
resource "aws_budgets_budget" "budget_less_six" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = "5.0"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2022-08-16_11:51"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["h.davoudy@gmail.com"]
  }
}


resource "aws_s3_bucket" "hdd" {
  bucket = "tf-gluejob-hotelbookings"
  acl    = "private" # why it does not let to make it private bucket
}
resource "aws_s3_bucket_object" "tf-gluejob-hotelbookings" {
  bucket = "tf-gluejob-hotelbookings"
  key    = "input_data/hotel_bookings.csv"
  acl    = "private"
  source = "C:\\Users\\hamed.davoudabadi\\PycharmProjects\\PySpark_Glue_2020809\\hotel_bookings.csv"
  etag   = filemd5("C:\\Users\\hamed.davoudabadi\\Datasets\\hotel_bookings\\hotel_bookings.csv")
}

#====================================================================
# Defining some variables for creating glue job and crawler
variable "job-language" {
  default = "python"
}
variable "glue_interactive_role" {
  default = "arn:aws:iam::015654357369:role/glue_interactive_role"
}
variable "job_name" {
  default = "hotelbooking_gluejob_triggered"
}
variable "bucket-terraform-script" {
  default = "tf-gluejob-hotelbookings"
}

variable "python-file-name" {
  default = "hotelbooking_gluejob.py"
}

variable "s3_input" {
  default = "tf-gluejob-hotelbookings/input_data"
}

variable "s3_ouput" {
  default = "tf-gluejob-hotelbookings/tf_output"
}


#======================================================================

# uploading glue's python script
resource "aws_s3_bucket_object" "upload-glue-script" {
  bucket = var.bucket-terraform-script
  key    = "scripts/${var.python-file-name}"
  source = var.python-file-name
}


# Creating a glue job


resource "aws_glue_job" "glue-job" {
  name     = var.job_name
  role_arn = var.glue_interactive_role
  command {
    script_location = "s3://${var.bucket-terraform-script}/scripts/${var.python-file-name}"
    python_version  = "3"
    name = "glueetl"

  }
  description       = "This is a script to create large files from small files"
  max_retries       = "1"
  number_of_workers = "2"
  timeout           = 2880
  worker_type       = "G.1X"
  execution_property {
    max_concurrent_runs = 1
  }
  glue_version = "3.0"
  default_arguments = {
    "--source_bucket"       = var.s3_input
    "--target_bucket"       = var.s3_ouput
    "--job-bookmark-option" = "job-bookmark-enable"
    "--job-language"        = "python"
    "--class"               = "GlueApp"
    "--input_s3"            = var.s3_input
    "--output_s3"           = var.s3_ouput
    }
}

resource "aws_glue_trigger" "aws_glue_trigger" {
  name = "aws_glue_trigger"
  type = "SCHEDULED"
  schedule = "cron(30 12 26 12 ? 2029)"
#  enabled = true
#  start_on_creation = true
  actions {
    job_name = "hotelbooking_gluejob_triggered"
  }
}

# Creating a crawler
resource "aws_glue_crawler" "hotelbookings_crawler" {
  database_name = "input_hotelbookings"
  name          = "hotelbookings_crawler"
  role          = "glue_interactive_role"
  table_prefix  = "terraform_"
  schedule      = "cron(30 12 26 12 ? 2029)"
  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "DEPRECATE_IN_DATABASE"
  }
#  recrawl_policy {
#    recrawl_behavior = "CRAWL_EVERYTHING"
#  }
  s3_target {
      path = "s3://tf-gluejob-hotelbookings/tf_output/df.parquet  "
#      exclusions : [
#        "string"
#      ]
#      sample_size = 1
    }
#  provisioner "local-exec" {
#    command = "aws glue start-crawler --hotelbookings_crawler"
#  }
}

#  configuration = var.configuration
#  s3_target {
#    path = ""
#  }
#dynamic "" {
#  for_each = ""
#  content {}
#}
#}
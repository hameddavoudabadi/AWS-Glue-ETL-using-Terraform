# AWS-Glue-ETL-using-Terraform
I will try to use Terraform to manage AWS Glue service and use Athena to query it's result. My steps in this learning process would be as mentioned in below:

1. Creating an ***AWS Budget*** to set a budget amount for using all services and also creating ***budget amout alert*** for sending an email when the threshold goes higher thant 80 percent of the budget.
2. Creating a ***s3 bucket***
3. Uploading a ***csv dataset to AWS s3 bucket***
4. Uploading a ***PySpark script*** and in the s3 bucket which will do the ETL process on the dataset in the AWS Glue Job
5. Creating a ***Glue Job*** for doing the ETL process by Terraform and transforming the csv file to a ***partitioned parquet*** file by year
6. Creating a ***Glue Trigger*** for starting the Glue Job on a specific date
7. Creating a ***Glue Crawler*** for making *data catalog* from the partitioned parquet file on a specific date
8. Running the PySpark code in the Glue Job which could be done by schedule or conditions
9. Using ***Athena*** to make some queries from the data catalog which has been created from the parquet file

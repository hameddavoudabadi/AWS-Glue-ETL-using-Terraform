import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'input_s3', 'output_s3'])

spark_context = SparkContext.getOrCreate()
glue_context = GlueContext(spark_context)
spark = glue_context.spark_session
job = Job(glue_context)
job.init('hotelbooking_gluejob')


#################################################################
# Read the source data from S3 bucket
#################################################################

df = spark.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load('s3://hotel-booking-aws-glue-spark/input/hotel_bookings.csv')
df.printSchema()
print("df shape: ",(df.count(), len(df.columns)))


#################################################################
# Loading
#################################################################

# Creating dynamic dataframe
dynamic_dframe = DynamicFrame.fromDF(df, glue_context, "dynamic_df")

# Writing data frame in s3 destination bucket
hotel_booking_v2 = glue_context.write_dynamic_frame.from_options(frame = dynamic_dframe, connection_type = "s3", format = "csv", connection_options = {"path": "s3://tf-gluejob-hotelbookings/tf_output/ ", "partitionKeys": []}, transformation_ctx = "DataSink0")
df.write.partitionBy("arrival_date_year").mode("overwrite").parquet("s3://tf-gluejob-hotelbookings/tf_output/df.parquet")



job.commit()
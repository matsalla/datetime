"""
AWS Lambda function to upload an HTML file with the current
datetime string to an S3 bucket
"""
import boto3
import json
import datetime
import logging
import os

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(os.getenv("LOG_LEVEL", logging.INFO))
s3_client = boto3.client("s3")


def current_datetime() -> str:
    """Get current date and time

    :return: datetime string 
    """
    return str(datetime.datetime.now())


def lambda_handler(event, context) -> dict:
    """Handler for AWS Lambda function

    :param dict event: AWS event object
    :param dict context: AWS context object

    :return: a status object with bucket and key
    """
    bucket = event.get("Bucket")
    if bucket is None:
        bucket = os.getenv("BUCKET")
    bucket_key = event.get("Key")
    if bucket_key is None:
        bucket_key = os.getenv("KEY")
    if bucket is None or bucket_key is None:
        logger.error("Bucket and Key must be set to a valid S3 bucket and key")
        return {
            "statusCode": 400
        }
    now = current_datetime()
    logger.info(f"Creating s3://{bucket}/{bucket_key} with contents of {now}")
    try:
        s3_response = s3_client.put_object(Bucket=bucket, Key=bucket_key, Body=now, CacheControl="max-age=60", ContentType="text/html")
    except Exception as exc:
        logger.error(f"Error writing to s3://{bucket}/{bucket_key}\n{str(exc)}")
        return {
            "statusCode": 400
        }
    if s3_response.get("ResponseMetadata", {}).get("HTTPStatusCode") != 200:
        logger.error(f"Error writing to s3://{bucket}/{bucket_key}\n{json.dumps(s3_response)}")
        return {
            "statusCode": 400
        }
    logger.debug(f"{s3_response=}")
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "datetime": now
        })
    }


if __name__ == "__main__":
    print(lambda_handler({"Key": "myfile.html"},{}))
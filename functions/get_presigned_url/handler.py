import os
import uuid
import boto3
import json
from botocore.exceptions import ClientError

s3 = boto3.client("s3")
BUCKET = os.environ["RECEIPTS_BUCKET"]


def lambda_handler(event, context):
    object_id = uuid.uuid4()
    try:
        url = s3.generate_presigned_url(
            "put_object",  # Specifies the PUT operation for uploading
            {"Bucket": BUCKET, "Key": str(object_id)},
            1000
        )
    except ClientError:
        return {
        "statusCode": 500,
        "body": json.dumps({"message": "unable to generate url"})
        }


    return {
        "statusCode": 200,
        "body": json.dumps({"pre_signed_url": url}),
    }

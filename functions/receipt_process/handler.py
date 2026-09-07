import base64
import os

import boto3

s3 = boto3.client("s3")
BUCKET = os.environ["RECEIPTS_BUCKET"]


def lambda_handler(event, context):
    receipt_id = event.get("pathParameters", {}).get("id")
    print(f"Processing receipt: {receipt_id}")

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "image/jpeg"},
        "isBase64Encoded": True,
        "body": null,
    }

import json
import os
import uuid

import boto3

s3 = boto3.client("s3")
BUCKET = os.environ["RECEIPTS_BUCKET"]


def lambda_handler(event, context):
    receipt_id = str(uuid.uuid4())

    return {
        "statusCode": 201,
        "body": json.dumps({"receiptId": receipt_id}),
    }

import json
import logging
import os
from urllib.parse import unquote_plus

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")
BUCKET = os.environ["RECEIPTS_BUCKET"]


def extract_objects(event):
    """Return (bucket, key) pairs from an SNS-wrapped S3 event."""
    objects = []
    for sns_record in event.get("Records", []):
        message = json.loads(sns_record["Sns"]["Message"])
        # S3 sends an s3:TestEvent with no Records when the notification is created.
        for s3_record in message.get("Records", []):
            bucket = s3_record["s3"]["bucket"]["name"]
            key = unquote_plus(s3_record["s3"]["object"]["key"])
            objects.append((bucket, key))
    return objects


def fetch_image(bucket, key):
    resp = s3.get_object(Bucket=bucket, Key=key)
    image = resp["Body"].read()
    logger.info(
        "Fetched s3://%s/%s (%d bytes, %s)",
        bucket, key, len(image), resp.get("ContentType"),
    )
    return image


def lambda_handler(event, context):
    processed = []
    for bucket, key in extract_objects(event):
        image = fetch_image(bucket, key)
        # TODO: process receipt image
        processed.append(key)

    return {"processed": processed}

import os
import sys
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
os.environ.setdefault("RECEIPTS_BUCKET", "test-bucket")

import infrastructure.functions.receipt_upload.handler as handler  # noqa: E402


@patch.object(handler, "s3")
def test_lambda_handler_returns_receipt_id(mock_s3):
    response = handler.lambda_handler({"body": "fake-image-bytes"}, None)

    assert response["statusCode"] == 201
    mock_s3.put_object.assert_called_once()

import base64
import os
import sys
from io import BytesIO
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
os.environ.setdefault("RECEIPTS_BUCKET", "test-bucket")

import infrastructure.functions.receipt_process.handler as handler  # noqa: E402


@patch.object(handler, "s3")
def test_lambda_handler_returns_base64_body(mock_s3):
    mock_s3.get_object.return_value = {"Body": BytesIO(b"fake-image-bytes")}

    response = handler.lambda_handler({"pathParameters": {"id": "abc-123"}}, None)

    assert response["statusCode"] == 200
    assert base64.b64decode(response["body"]) == b"fake-image-bytes"

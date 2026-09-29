output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "notification_topic_arn" {
  value = aws_sns_topic.this.arn
}

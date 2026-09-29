output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "notification_topic_arn" {
  value = aws_sns_topic.this.arn
}

output "sns_delivery_log_group_names" {
  value = [
    aws_cloudwatch_log_group.sns_success.name,
    aws_cloudwatch_log_group.sns_failure.name,
  ]
}

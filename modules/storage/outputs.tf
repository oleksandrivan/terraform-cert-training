output "bucket_name" {
  description = "Lab bucket name."
  value       = try(aws_s3_bucket.lab[0].bucket, null)
}

output "bucket_arn" {
  description = "Lab bucket ARN."
  value       = try(aws_s3_bucket.lab[0].arn, null)
}

output "efs_id" {
  description = "EFS file system id."
  value       = try(aws_efs_file_system.lab[0].id, null)
}

output "bucket_name" {
  description = "Pass this to backend \"s3\" bucket."
  value       = aws_s3_bucket.state.bucket
}

output "dynamodb_table_name" {
  description = "Legacy lock table. Omit dynamodb_table in the backend block when you rely on use_lockfile."
  value       = try(aws_dynamodb_table.locks[0].name, null)
}

output "backend_snippet" {
  description = "Starter backend block. The bootstrap stack itself stays on the local backend."
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket       = "${aws_s3_bucket.state.bucket}"
        key          = "labs/08-eks-platform/terraform.tfstate"
        region       = "${var.aws_region}"
        encrypt      = true
        use_lockfile = true
      }
    }
  EOT
}

variable "origin_domain_name" {
  type = string
  default = null
  description = "Fully qualified DNS name for the origin server. This may be an S3 bucket, ELB, or a custom origin name."
}
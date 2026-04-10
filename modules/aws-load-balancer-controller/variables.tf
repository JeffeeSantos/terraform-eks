variable "project_name" {
  type        = string
  description = "Project name to be used to name the resources (Name tag)"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be applied to AWS resources"
}

variable "oidc" {
  type        = string
  default     = ""
  description = "HTTPS URL from OIDC provider of the EKS cluster"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "aws_vpc_id" {
  type        = string
  description = "ID of the AWS VPC"
}

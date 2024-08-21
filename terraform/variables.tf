variable "aws_region" {
  description = "The AWS region to deploy resources to."
  default     = "us-east-2"
}

variable "key_pair_name" {
  description = "The name of the key pair to use for SSH access."
  default     = "DBtest"
}


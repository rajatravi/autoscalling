variable "asg_max" {
  default = "5"
}

variable "asg_min" {
  default = "2"
}

variable "asg_desired" {
  default = "2"
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC"
  default     = false
}

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring. This is enabled by default."
  default     = false
}

variable "instance_subnets" {
  default = []
}

variable "ami_id" {}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = ""
}


variable "security_group_ids" {
  type = "list"
}

variable "user_data" {
  default = ""
}


variable "zone_id" {}

variable "iam_instance_profile" {
  default = ""
}

variable "suspended_processes" {
  default = []
}

variable "asg_root_volume_type" {
  default = "gp2"
}

variable "asg_root_volume_size" {
  default = "50"
}


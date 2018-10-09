variable "asg_max" {
  default = "2"
}

variable "asg_min" {
  default = "1"
}

variable "asg_desired" {
  default = "1"
}

variable "name" {
  default = "lybrate_autosaclling"
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
  default = "subnet-ba1445cc"
}

variable "ami_id" {
  default = "ami-0725b40295062a0ab"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "rajat"
}


variable "security_group_ids" {
  type = "string"
  default = "apache_sg"
}

variable "user_data" {
  default = "sudo apt-get update"
}


variable "asg_root_volume_type" {
  default = "gp2"
}

variable "asg_root_volume_size" {
  default = "15"
}


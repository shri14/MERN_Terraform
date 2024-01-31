variable "region" {
  description = "The AWS region to deploy the resources into."
  default     = "ap-south-1"

}
variable "http_cidr" {
  type    = string
  default = "0.0.0.0/0"

}
variable "http_ingress" {
  type    = number
  default = 80

}
variable "ssh_cidr" {
  type        = string
  description = "CIDR block for SHH ingress"
  default     = "0.0.0.0/0"
}
variable "ssh_ingress" {
  type    = number
  default = 22
}
variable "app_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
variable "application_ingress" {
  type    = number
  default = 3000

}
variable "https_ingress" {
  type    = number
  default = 443

}

variable "https_cder" {
  type    = string
  default = "0.0.0.0/0"

}
variable "ami" {
  type    = string
  default = "ami-03f4878755434977f"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

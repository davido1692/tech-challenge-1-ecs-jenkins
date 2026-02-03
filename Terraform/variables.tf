variable "project" {
  type    = string
  default = "tc1"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "container_port_frontend" {
  type    = number
  default = 3000
}

variable "container_port_backend" {
  type    = number
  default = 8080
}

# You will push images to ECR and set tags. Example: "latest" or a git sha.
variable "frontend_image_tag" {
  type    = string
  default = "latest"
}

variable "backend_image_tag" {
  type    = string
  default = "latest"
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count_frontend" {
  type    = number
  default = 1
}

variable "desired_count_backend" {
  type    = number
  default = 1
}

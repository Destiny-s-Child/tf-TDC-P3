variable "default_tags" {
  type = map(string)
  default = {
    "env" = "tdc-p3"
  }
  description = "TDC Variables"
}

variable "public_subnet_count" {
  type        = number
  description = "Public Subnet Count"
  default     = 2
}

variable "private_subnet_count" {
  type = number
  description = "Private Subnet Count"
  default = 2 
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
  description = "TDC's Main VPC CIDR Block"
}
variable "sg_db_ingress" {
  type = map(object({
    port = number
    protocol = string
    self = bool
  }))
  default = {
    "mysql" = {
      port = 3306
      protocol = "tcp"
      self = true
    }
  }
}
variable "sg_db_egress" {
  type = map(object({
    port = number
    protocol = string
    self = bool
  }))
  default = {
    "all" = {
      port = 0
      protocol = "-1" # signal to use every available protocol
      self = true
    }
  }
}
variable "db_credentials" {
  type = map(any)
  sensitive = true # will not print into to terminal
  default = {
    username = "username"
    password = "password"
  }
}
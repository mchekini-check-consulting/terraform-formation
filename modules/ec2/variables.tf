variable "ec2-instances" {
  type = list(object({
    subnet: string
    type: string
    ami : string
  }))
}

variable "vpc-id" {
  type = string
  default = "vpc-03c2264ac35ea0b41"
}

variable "waf-arn" {
  type = string
}

variable "certificate-arn" {
  type = string
}
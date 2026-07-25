variable "student_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "public_zone_arn" {
  type = string
  default = null
}

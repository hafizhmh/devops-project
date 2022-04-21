variable "project" {}

variable "credentials_file" {}

variable "database_admin_password" {}


variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}

variable "node_count" {
  default = "5"
}
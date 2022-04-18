variable "project" {}

variable "credentials_file" {}

variable "startup_file" {
  default = "startupscript.sh"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}
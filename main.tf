terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}
provider "google-beta" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_sql_database_instance" "sql-db-instance-1" {
  provider         = google-beta
  name             = "sql-db-instance-1"
  database_version = "MYSQL_8_0"
  root_password    = var.database_admin_password
  deletion_protection = false
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name = "all"
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "google_sql_database" "fintax-mysql-db" {
  name     = "fintax_mysql_db"
  instance = google_sql_database_instance.sql-db-instance-1.name
}

resource "google_sql_user" "fintax-mysql-users" {
  name     = "admin"
  instance = google_sql_database_instance.sql-db-instance-1.name
  password = var.database_admin_password
}


resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_instance" "alpha_server" {
  name         = "alpha-server"
  machine_type = "f1-micro"
  tags         = ["ssh", "alphaserver", "http-server"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
  metadata_startup_script = data.template_file.startup_script_server.rendered
  service_account {
    scopes = ["storage-ro"]
  }
}

resource "google_compute_instance" "alpha-client-" {
  count        = var.node_count
  name         = "alpha-client-${count.index}"
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["ssh", "alphaclient"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  attached_disk {
    source      = element(google_compute_disk.alpha-client-disk-.*.self_link, count.index)
    device_name = element(google_compute_disk.alpha-client-disk-.*.name, count.index)
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
  metadata_startup_script = data.template_file.startup_script_client.rendered
}

resource "google_compute_disk" "alpha-client-disk-" {
  count = var.node_count
  name  = "alpha-client-disk-${count.index}-data"
  type  = "pd-standard"
  zone  = var.zone
  size  = "5"
}

resource "google_compute_firewall" "terraform-fw" {
  name    = "terraform-fw"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22","80"]
  }
  target_tags   = ["alphaclient", "alphaserver"]
  source_ranges = ["0.0.0.0/0"]
}
resource "google_storage_bucket" "script_bucket" {
  name          = var.bucket_name
  location      = "US"
  force_destroy = true
}

resource "google_storage_bucket_object" "script_obj" {
  name   = "server.py"
  source = "server.py"
  bucket = google_storage_bucket.script_bucket.name
}

resource "google_storage_bucket_object" "requirement_obj" {
  name   = "requirement.txt"
  source = "requirement.txt"
  bucket = google_storage_bucket.script_bucket.name
}

resource "google_storage_bucket_object" "server_config_obj" {
  name   = "server.config"
  source = "server.config"
  bucket = google_storage_bucket.script_bucket.name
}

output "ip_abc" {
  value = google_compute_instance.alpha_server.network_interface.0.access_config.0.nat_ip
}

output "api_path" {
  value = "GET http://${google_compute_instance.alpha_server.network_interface.0.access_config.0.nat_ip}/hostname_count"
}

output "sql_ip" {
  value = google_sql_database_instance.sql-db-instance-1.ip_address.0.ip_address
}

data "template_file" "startup_script_client" {
  template = file("startup-client.sh")
  vars = {
    alpha_server_ip = google_compute_instance.alpha_server.network_interface.0.access_config.0.nat_ip
  }
}

data "template_file" "startup_script_server" {
  template = file("startup-server.sh")
  vars = {
    sql_ip = google_sql_database_instance.sql-db-instance-1.ip_address.0.ip_address
    bucket_name = var.bucket_name
  }
}
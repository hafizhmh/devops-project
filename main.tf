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

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_instance" "alpha_server" {
  name         = "alpha-server"
  machine_type = "f1-micro"
  tags         = ["ssh", "alphaserver"]
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
  # metadata_startup_script = file(var.startup_file)
  metadata_startup_script = data.template_file.startup_script.rendered
}

resource "google_compute_disk" "alpha-client-disk-" {
  count = var.node_count
  name  = "alpha-client-disk-${count.index}-data"
  type  = "pd-standard"
  zone  = var.zone
  size  = "5"
}

resource "google_compute_firewall" "ssh-http-rule" {
  name    = "terraform-fw"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }
  target_tags   = ["alphaclient", "alphaserver"]
  source_ranges = ["0.0.0.0/0"]
}
output "ip_abc" {
  value = google_compute_instance.alpha_server.network_interface.0.access_config.0.nat_ip
}

data "template_file" "startup_script" {
  template = file("startupscript.sh")
  vars = {
    echo_ip = google_compute_instance.alpha_server.network_interface.0.access_config.0.nat_ip
  }
}
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

resource "google_compute_instance" "vm_instance" {
  name         = "nodeabc"
  machine_type = "f1-micro"
  tags         = ["ssh", "alphaclient"]
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
  # metadata_startup_script = file(var.startup_file)
  metadata_startup_script = data.template_file.startup_script.rendered
}

resource "google_compute_firewall" "ssh-http-rule" {
  name = "terraform-fw"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports = ["22", "80"]
  }
  target_tags = ["alphaclient", "alphaserver"]
  source_ranges = ["0.0.0.0/0"]
}
output "ip_abc" {
  value = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
}

data "template_file" "startup_script" {
  template = file("startupscript.sh")
  vars = {
    echo_ip = "test123"
  }
}
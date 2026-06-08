provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable Cloud Run API
resource "google_project_service" "cloudrun_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Random suffix for unique service name
resource "random_id" "suffix" {
  byte_length = 4
}

# Cloud Run V2 Service optimized for Free Tier
resource "google_cloud_run_v2_service" "default" {
  name                = "${var.service_name}-${random_id.suffix.hex}"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  template {
    scaling {
      max_instance_count = 1 # Prevent scaling to stay within free tier
    }

    containers {
      image = var.image_url
      ports {
        container_port = 80
      }
      resources {
        limits = {
          cpu    = "1"     # 1 vCPU (minimum for standard instances)
          memory = "256Mi" # Low memory to maximize free tier seconds
        }
        cpu_idle = true # CPU only allocated during request processing (Free Tier)
      }
    }
  }

  depends_on = [google_project_service.cloudrun_api]
}

# Allow unauthenticated access
resource "google_cloud_run_v2_service_iam_member" "noauth" {
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

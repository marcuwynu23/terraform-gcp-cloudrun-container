variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy the Cloud Run service (Must be us-central1, us-east1, or us-west1 for Free Tier)"
  type        = string
  default     = "us-central1"

  validation {
    condition     = contains(["us-central1", "us-east1", "us-west1"], var.region)
    error_message = "Region must be one of the GCP Always Free regions: us-central1, us-east1, or us-west1."
  }
}

variable "service_name" {
  description = "The name of the Cloud Run service"
  type        = string
  default     = "nginx-service"
}

variable "image_url" {
  description = "The container image URL"
  type        = string
  default     = "nginx:latest"
}

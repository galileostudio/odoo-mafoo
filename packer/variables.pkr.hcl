variable "project_id" {
  type        = string
  description = "GCP Project ID where the image will be created"
}

variable "source_image_family" {
  type        = string
  default     = "debian-11"
  description = "Source image family for the build"
}

variable "zone" {
  type        = string
  default     = "southamerica-east1-a"
  description = "GCP zone where the build will be executed"
}

variable "image_name" {
  type        = string
  default     = "odoo-production-ready"
  description = "Name of the resulting image"
}

variable "image_family" {
  type        = string
  default     = "odoo-production"
  description = "Family name of the image"
}

variable "image_description" {
  type        = string
  default     = "Odoo Production Ready Image"
  description = "Description of the image"
}

variable "machine_type" {
  type        = string
  default     = "e2-medium"
  description = "Machine type used for the build"
}

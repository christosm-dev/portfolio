# Variables - Make the configuration flexible and reusable

variable "container_name" {
  description = "Name of the Docker container"
  type        = string
  default     = "terraform-nginx"
}

variable "image_name" {
  description = "Docker image to use"
  type        = string
  default     = "nginx:latest"
}

variable "external_port" {
  description = "External port to expose the container on"
  type        = number
  default     = 8080
  
  validation {
    condition     = var.external_port > 1024 && var.external_port < 65535
    error_message = "External port must be between 1024 and 65535."
  }
}

variable "internal_port" {
  description = "Internal container port"
  type        = number
  default     = 80
}

variable "keep_image_locally" {
  description = "Whether to keep the Docker image locally after destruction"
  type        = bool
  default     = false
}

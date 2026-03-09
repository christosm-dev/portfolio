# Remote State Backend - Consul
#
# Terraform stores state locally by default (terraform.tfstate on disk).
# This backend block tells Terraform to store state in Consul's key-value
# store instead, which provides:
#
#   - Durability: state survives local machine failures
#   - Locking:    Consul prevents concurrent applies from corrupting state
#   - Shareability: any machine that can reach Consul can run terraform apply
#
# Before running `terraform init`, start Consul with:
#   docker compose -f docker-compose.consul.yml up -d
#
# Consul UI is then available at http://localhost:8500
# State is stored at key: project1/terraform.tfstate

terraform {
  backend "consul" {
    address = "localhost:8500"
    scheme  = "http"
    path    = "project1/terraform.tfstate"
    lock    = true
  }
}

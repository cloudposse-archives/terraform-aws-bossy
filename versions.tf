terraform {
  required_version = ">= 1.0"

  required_providers {
    # Update these to reflect the actual requirements of your module
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}

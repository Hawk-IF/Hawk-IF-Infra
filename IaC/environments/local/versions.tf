terraform {
    required_version = ">= 1.8.0"

    required_providers {
        docker = {
            source  = "kreuzwerker/docker"
            version = "4.7.0"
        }

        local = {
                source  = "hashicorp/local"
                version = "2.9.1"
        }
    }

}
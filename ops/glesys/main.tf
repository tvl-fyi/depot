# Configure TVL resources hosted with GleSYS.
#
# Most importantly:
#  - all of our DNS
#  - object storage (e.g. backups)

terraform {
  required_providers {
    glesys = {
      source = "depot/glesys"
    }
  }
}

provider "glesys" {
  userid = "cl26117" # generated by GleSYS
}

resource "glesys_objectstorage_instance" "tvl-backups" {
  description = "tvl-backups"
  datacenter = "dc-sto1"
}

locals {
  railway_backups_bucket = "lrstanley-railway-backups"
}

resource "cloudflare_r2_bucket" "railway_backups" {
  account_id = var.cloudflare_account_id
  name       = local.railway_backups_bucket
  location   = "enam"
}

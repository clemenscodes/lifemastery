provider "google" {}

module "app1" {
  source = "./apps/clients/web/finance"
}

module "app2" {
  source = "./apps/clients/web/landing"
}

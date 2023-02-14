locals {
  ip_name         = "${var.bucket}-ip"
  url_map         = "${var.bucket}-https-lb"
  proxy_name      = "${local.url_map}-proxy"
  forwarding_rule = "${local.url_map}-forwarding-rule"
  domain          = "${var.subdomain}.${var.domain}"
}

module "cdn_bucket" {
  source     = "../bucket/cdn_bucket"
  region     = var.region
  bucket     = var.bucket
  project_id = var.project_id
}

resource "google_compute_global_address" "default" {
  name         = local.ip_name
  project      = var.project_id
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_compute_backend_bucket" "default" {
  project     = var.project_id
  name        = var.bucket
  bucket_name = var.bucket
  enable_cdn  = true
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    negative_caching  = true
    serve_while_stale = 86400
  }
}

resource "google_compute_url_map" "default" {
  name            = local.url_map
  project         = var.project_id
  default_service = google_compute_backend_bucket.default.id
}

resource "google_compute_managed_ssl_certificate" "default" {
  name    = var.certificate_name
  project = var.project_id
  lifecycle {
    create_before_destroy = true
  }
  managed {
    domains = [local.domain]
  }
}

resource "google_compute_target_https_proxy" "default" {
  name             = local.proxy_name
  project          = var.project_id
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = local.forwarding_rule
  project               = var.project_id
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}

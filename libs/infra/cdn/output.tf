output "ip" {
  value = google_compute_global_address.default.address
}

output "subdomain" {
  value = var.subdomain
}

output "domain" {
  value = var.domain
}

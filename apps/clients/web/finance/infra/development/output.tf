output "url" {
  value = module.run.url
}

output "ip" {
  value = module.finance.ip
}

output "subdomain" {
  value = module.finance.subdomain
}

output "domain" {
  value = module.finance.domain
}

output "cloud_run_subdomain" {
  value = module.run.cloud_run_subdomain
}

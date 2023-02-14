output "org_name" {
  value = module.workload_identity_federation.org_name
}

output "service_account_email" {
  value = module.workload_identity_federation.service_account_email
}

output "provider" {
  value = module.workload_identity_federation.provider
}

output "ip" {
  value = module.cdn.ip
}

output "subdomain" {
  value = module.cdn.subdomain
}

output "domain" {
  value = module.cdn.domain
}

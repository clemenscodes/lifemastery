output "org_name" {
  value = data.google_organization.org.name
}

output "service_account_email" {
  value = google_service_account.gh_actions.email
}
output "bucket_service_account" {
    value = google_service_account.bucket.email
}

output "bucket_name" {
    value = google_storage_bucket.state_bucket.name
}

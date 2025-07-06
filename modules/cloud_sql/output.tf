output "instance_connection_name" {
  value = google_sql_database_instance.this.connection_name
}

output "private_ip" {
  value = (
    length([
      for ip in google_sql_database_instance.this.ip_address : ip.ip_address
      if ip.type == "PRIVATE"
    ]) > 0 ?
    [
      for ip in google_sql_database_instance.this.ip_address : ip.ip_address
      if ip.type == "PRIVATE"
    ][0] : null
  )
}

output "db_username" {
  value = var.db_username
}

output "db_password" {
  value     = var.db_password
  sensitive = true
}

output "db_name" {
  value     = var.db_name
  sensitive = true
}

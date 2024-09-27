output "data-base-username" {
  value = jsondecode(data.aws_secretsmanager_secret_version.credentials.secret_string)["username"]
}

output "data-base-password" {
  value = jsondecode(data.aws_secretsmanager_secret_version.credentials.secret_string)["password"]
}
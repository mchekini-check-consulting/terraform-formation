resource "random_password" "database-password" {
  length = 16
  special = false
}


resource "aws_secretsmanager_secret" "data-base-password" {
  name = "my-database-password"
}


resource "aws_secretsmanager_secret_version" "credentials" {
  secret_id = aws_secretsmanager_secret.data-base-password.id
  secret_string = jsonencode({
    "username" : "postgres",
    "password" : random_password.database-password.result
  })
}

data "aws_secretsmanager_secret_version" "credentials" {
  secret_id = aws_secretsmanager_secret.data-base-password.id
}
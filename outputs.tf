output "customer_public_endpoint" {
  value       = "http://${aws_instance.customer.public_ip}:9091"
  description = "The public endpoint to query the frontend Customer service"
}

output "account_private_ip" {
  value       = aws_instance.account.private_ip
  description = "Internal network IP for Account service"
}

output "statement_private_ip" {
  value       = aws_instance.statement.private_ip
  description = "Internal network IP for Statement service"
}

output "ssh_key_generated" {
  value       = local.private_key_filename
  description = "The local filename of your generated private key file."
}
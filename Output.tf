output "publicip" {
  description = "Value of public IP address assigned to the instance."
  value       = [for instance in aws_instance.frontend : instance.public_ip]
}

output "public_key" {
  description = "Public key content for the frontend key pair"
  value       = aws_key_pair.frontendkey.public_key
}

output "private_key_path" {
  description = "File path to the private key for the frontend key pair"
  value       = local_file.frontend_private_key.filename
}


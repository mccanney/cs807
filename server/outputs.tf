output "public_ip" {
  description = "The public IP of the server."
  value       = aws_spot_instance_request.this.public_ip
}

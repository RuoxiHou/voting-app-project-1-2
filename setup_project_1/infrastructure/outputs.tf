output "bastion_public_ip" {
  value = {
    for key, instance in aws_instance.bastion :
    key => instance.public_ip
  }
}

output "frontend_private_ips" {
  value = {
    for key, instance in aws_instance.frontend :
    key => instance.private_ip
  }
}


output "middleware_private_ips" {
  value = {
    for key, instance in aws_instance.middleware :
    key => instance.private_ip
  }
}


output "postgres_primary_private_ip" {
  value = aws_instance.postgres_primary.private_ip
}

output "postgres_standby_private_ip" {
  value = aws_instance.postgres_replica.private_ip
}
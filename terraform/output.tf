///////////////////////////////////// EC2 instances /////////////////////////////////
// Public/NAT instance info.
output "instance_public_id" {
  value = aws_instance.instance_public.id
}

output "instance_public_dns" {
  value = aws_instance.instance_public.public_dns
}

output "instance_public_ip" {
  value = aws_instance.instance_public.public_ip
}

// Private instance info.
output "instance_private_id" {
  value = aws_instance.instance_private.id
}

output "instance_private_ip" {
  value = aws_instance.instance_private.private_ip
}
////////////////////////////////////////////////////////////////////////////////////////

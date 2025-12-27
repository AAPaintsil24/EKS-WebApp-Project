output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_k8s_subnet_ids" {
  value = [for k, s in aws_subnet.private : s.id if contains(k, "k8s")]
}

output "private_db_subnet_ids" {
  value = [for k, s in aws_subnet.private : s.id if contains(k, "db")]
}
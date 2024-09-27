output "lb-dns" {
  value = aws_lb.my-lb[0].dns_name
}

output "lb-zone-id" {
  value = aws_lb.my-lb[0].zone_id
}
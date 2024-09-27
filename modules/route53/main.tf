resource "aws_route53_record" "my-record" {
  name    = var.domain-name
  type    = "A"
  zone_id = var.hosted-zone-id

  alias {
    evaluate_target_health = false
    name                   = var.alb-dns
    zone_id                = var.alb-zone-id
  }
}
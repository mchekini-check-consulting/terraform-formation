resource "aws_acm_certificate" "my-certificate" {

  domain_name = "check-consulting.net"
  subject_alternative_names = ["test.check-consulting.net"]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_route53_record" "resolve-dns-challenge" {
    for_each = {
      for dvo in aws_acm_certificate.my-certificate.domain_validation_options : dvo.domain_name => {
        name = dvo.resource_record_name
        type = dvo.resource_record_type
        record = dvo.resource_record_value
      }
    }

  zone_id = var.zone-id
  name = each.value.name
  type = each.value.type
  ttl = 10
  records = [each.value.record]

}


resource "aws_acm_certificate_validation" "cert-validation" {
  certificate_arn = aws_acm_certificate.my-certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.resolve-dns-challenge : record.fqdn]
}







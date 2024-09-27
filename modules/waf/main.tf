resource "aws_wafv2_web_acl" "block-countries-acl" {
  name  = "block-countries-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "geolocation-block-countries"
    sampled_requests_enabled   = false
  }

  rule {
    name     = "geolocation-block-country-rule"
    priority = 1
    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = var.blocked_countries
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "geolocation-block-countries"
      sampled_requests_enabled   = false
    }


  }
}
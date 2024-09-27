locals {
  local_data = jsondecode(file("./config.json"))
}


module "s3" {
  source = "./modules/s3"
  buckets = local.local_data.buckets
}

module "acm" {
  source = "./modules/acm"
  domain-name = local.local_data.domain
}

module "waf" {
  source = "./modules/waf"
  blocked_countries = local.local_data.blocked_countries
}

module "ec2" {
  source = "./modules/ec2"
  ec2-instances = local.local_data.ec2Instances
  waf-arn = module.waf.waf_arn
  certificate-arn = module.acm.certificate-arn
  depends_on = [module.waf, module.acm]
}


module "route-53" {
  source = "./modules/route53"
  domain-name = local.local_data.domain
  alb-dns = module.ec2.lb-dns
  alb-zone-id = module.ec2.lb-zone-id
  depends_on = [module.ec2]
}


#module "secrets-manager" {
#  source = "./modules/secrets-manager"
#}


#module "rds" {
#  source = "./modules/rds"
#  db-username = module.secrets-manager.data-base-username
#  db-password = module.secrets-manager.data-base-password
#}
















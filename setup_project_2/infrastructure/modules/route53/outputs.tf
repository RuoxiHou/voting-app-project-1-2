output "public_zone_id" {
  value = data.aws_route53_zone.public.zone_id
}

output "public_zone_name" {
  value = data.aws_route53_zone.public.name
}

output "public_zone_arn" {
  value = data.aws_route53_zone.public.arn
}
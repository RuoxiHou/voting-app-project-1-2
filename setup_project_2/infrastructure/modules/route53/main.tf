locals {
  name_prefix = "${var.project_name}-${var.student_name}"
}

data "aws_route53_zone" "public" {
  zone_id = var.hosted_zone_id
}

output "alb_dns_name" {
  value = aws_lb.my_alb.dns_name
}
output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}
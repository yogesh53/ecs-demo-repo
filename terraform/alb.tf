data "aws_acm_certificate" "ssl_cert" {
  domain      = "demo.yogeshkr.shop"
  statuses    = ["ISSUED"]
  most_recent = true
}
resource "aws_lb" "my_alb" {
  name = "my-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  tags = {
    Name = "my-alb"
  }
}
resource "aws_lb_target_group" "my_tg" {
  name = "my-alb-tg"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id
  health_check {
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 25
    unhealthy_threshold = 5
    healthy_threshold   = 2
  }
  tags = {
    Name = "my-alb-tg"
  }
}
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ssl_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}
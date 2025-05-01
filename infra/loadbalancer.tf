resource "aws_lb" "alb" {
  name               = var.alb_name
  security_groups    = [aws_security_group.nlb_security.id]
  subnets            = var.subnets

  internal           = false
  load_balancer_type = "application"
}

resource "aws_security_group" "alb_security" {
  name = "calculadora_alb_security"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "out_alb" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_security.id
}
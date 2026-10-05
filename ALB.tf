#target group creation
resource "aws_lb_target_group" "WEB_tg" {
  name     = "WEB-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Project3.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

  tags = {
    Name = "WEB-target-group"
  }
}

#target group associations

resource "aws_lb_target_group_attachment" "web1_tg_attach" {
  target_group_arn = aws_lb_target_group.WEB_tg.arn
  target_id        = aws_instance.Public-web-server[0].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2_tg_attach" {
  target_group_arn = aws_lb_target_group.WEB_tg.arn
  target_id        = aws_instance.Public-web-server[1].id
  port             = 80
}

#Alb for web

resource "aws_lb" "web_alb" {

  name               = "WEB-alb"
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.WEB-security-group.id
  ]

  subnets = [
    aws_subnet.Public-subnet-1.id,
    aws_subnet.Public-subnet-2.id
  ]

  tags = {
    Name = "WEB-alb"
  }
}

#alb listeners

resource "aws_lb_listener" "web_listener" {

  load_balancer_arn = aws_lb.web_alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.WEB_tg.arn
  }
}

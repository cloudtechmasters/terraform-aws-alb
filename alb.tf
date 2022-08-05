data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_alb" "alb" {
  name             = "terraform-example-alb"
  //security_groups  = var.security_groups
  security_groups = [aws_security_group.testsg.id]
  subnets          = data.aws_subnet_ids.all.ids

  depends_on = [aws_security_group.testsg]
}

resource "aws_alb_target_group" "group" {
  name     = "terraform-example-alb-target"
  port     = 33333
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/listallcustomers"
    port = 33333
  }
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.group.arn
    type             = "forward"
  }
}

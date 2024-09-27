resource "aws_security_group" "insatance-sg" {
  name = "ec2-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "lb-sg" {
  name = "alb-sg"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "ec2-instance" {
  count                  = length(var.ec2-instances)
  ami                    = var.ec2-instances[count.index].ami
  instance_type          = var.ec2-instances[count.index].type
  subnet_id              = var.ec2-instances[count.index].subnet
  vpc_security_group_ids = [aws_security_group.insatance-sg.id]
  user_data              = templatefile("./scripts/init.tftpl", { instanceNumber = count.index + 1 } )
  tags                   = {
    Name = "instance-${count.index+1}"
  }
}


resource "aws_lb" "my-lb" {

  count              = length(var.ec2-instances) > 1 ? 1 : 0
  name               = "my-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [for sid in var.ec2-instances : sid.subnet]

}

resource "aws_lb_target_group" "my-tg" {
  count       = length(var.ec2-instances) > 1 ? 1 : 0
  name        = "my-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc-id

}


resource "aws_lb_target_group_attachment" "my-tg-attachements" {
  count            = length(var.ec2-instances) > 1 ? length(var.ec2-instances) : 0
  target_group_arn = aws_lb_target_group.my-tg[0].arn
  target_id        = aws_instance.ec2-instance[count.index].id

}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my-lb[0].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_listener" "my-listner" {
  count             = length(var.ec2-instances) > 1 ? 1 : 0
  load_balancer_arn = aws_lb.my-lb[0].arn
  port = 443
  protocol = "HTTPS"
  certificate_arn = var.certificate-arn


  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.my-tg[0].arn
  }
}


resource "aws_lb_listener_rule" "my-rule" {

  count = length(var.ec2-instances) > 1 ? 1 : 0
  listener_arn = aws_lb_listener.my-listner[0].arn
  priority = 100 + count.index

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.my-tg[0].arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }

}


resource "aws_wafv2_web_acl_association" "waf-lb-association" {
  resource_arn = aws_lb.my-lb[0].arn
  web_acl_arn  = var.waf-arn
}


















resource "aws_security_group" "alb" {
  name   = "${var.environment}-alb-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_security_group" "app" {
  name   = "${var.environment}-app-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.environment}-app-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  health_check {
    path = "/health"
  }
}

resource "aws_launch_template" "app_template" {
  name_prefix   = "${var.environment}-app-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app.id]
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name_prefix         = "${var.environment}-asg-"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  min_size            = var.min_instances
  max_size            = var.max_instances
  desired_capacity    = var.desired_instances
  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }
}
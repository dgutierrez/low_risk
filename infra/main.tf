provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "CalculadoraCluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "CalculadoraCluster"
    Environment = "production"
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.ecs_cluster.name
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.ecs_security_group.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  depends_on = [
    aws_security_group.ecs_security_group 
  ]
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.app_role.arn 
  task_role_arn            = aws_iam_role.app_role.arn
  container_definitions = jsonencode([{
    # Defina as configurações do seu contêiner aqui
    "name"      : "CalculadoraApiServices",
    "image"     : "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/ecs_calculadora_api:171824e8069bc78498ef5e923cb3b25aa5fada06",
    
    "essential" : true,
    "portMappings": [{
      "containerPort": 5010,
      "hostPort": 5010,
      "protocol": "tcp"
    }],
    "environment": [
      {
        "name": "PORT",
        "value": "5010"
      },
      {
        "name": "ASPNETCORE_HTTP_PORTS",
        "value": "5010"
      },
      {
        "name": "HEALTHCHECK",
        "value": "/"
      },
      {
        "name": "ENABLE_LOGGING",
        "value": "false"
      },
      {
        "name": "ENVIRONMENT",
        "value": "prod"
      },
      {
        "name": "ASPNETCORE_ENVIRONMENT",
        "value": "prod"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/CalculadoraApiServices/",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }])
}


resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.container_port
  protocol          = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

resource "aws_security_group_rule" "tcp_alb" {
  type              = "ingress"
  from_port         = var.container_port
  to_port           = var.container_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_security.id
}

resource "aws_lb_target_group" "blue" {
  name     = "${var.service_name}-tg-blue"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    interval            = 30
    timeout             = 15
    healthy_threshold   = 5
    unhealthy_threshold = 5
    matcher             = "200-299"
  }
}

resource "aws_lb_target_group" "green" {
  name     = "${var.service_name}-tg-green"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    interval            = 30
    timeout             = 15
    healthy_threshold   = 5
    unhealthy_threshold = 5
    matcher             = "200-299"
  }
}

resource "aws_codedeploy_app" "ecs_app" {
  name = "AppECS-CalculadoraCluster-CalculadoraApiServices"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "ecs_dg" {
  app_name               = aws_codedeploy_app.ecs_app.name
  deployment_group_name  = "DgpECS-CalculadoraCluster-CalculadoraApiServices"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"

  deployment_style {
    deployment_type = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                             = "TERMINATE"
      termination_wait_time_in_minutes  = 5
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs_cluster.name
    service_name = aws_ecs_service.ecs_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.alb_listener.arn]
      }

      target_group {
        name = aws_lb_target_group.blue.name
      }

      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }
}

resource "aws_security_group" "ecs_security_group" {
  name        = "ecs_security_group-${var.service_name}"
  description = "Security group para o servico ECS"
  vpc_id      = var.vpc_id

  ingress {
    description = "Permitir trafego na porta 5010"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    description = "Permitir todo o trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-security-group"
  }
}

resource "aws_cloudwatch_log_group" "my_log_group" {
  name = "/ecs/CalculadoraApiServices/"  

  tags = {
    Environment = "Production",
    Application = "CalculadoraApiServices"
  }
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.ecs_cluster.name
  description = "Nome do cluster ECS criado"
}
  
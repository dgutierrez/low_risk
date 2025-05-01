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

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener_rule.alb_listener_rule,
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
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    # Defina as configurações do seu contêiner aqui
    "name"      : "CalculadoraApiServices",
    "image"     : "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/ecs_calculadora_api:v1.1",
    
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
    "compatibilities": ["FARGATE"],
    "requiresCompatibilities" : ["FARGATE"]
  }])
}


resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.container_port
  protocol          = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

resource "aws_lb_listener_rule" "alb_listener_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn  
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
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

resource "aws_lb_target_group" "ecs_tg" {
  name        = "${var.service_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
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
  
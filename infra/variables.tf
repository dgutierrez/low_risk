variable "alb_name"{
    type = string
    default = "calculadora-applb"
}

variable "nlb_name"{
    type = string
    default = "calculadora-netlb"
}

variable "vpc_id"{
    type = string
    default = "vpc-07b4251d2601fba2d"
}

variable "subnets"{
    type = list(string)
    default = [ "subnet-04212cadd784e9d94", "subnet-0af742977e1f4edee", "subnet-0cc1289caf4bcee8f", "subnet-01c0af08e99846282", "subnet-0ef16b943cf37c00b", "subnet-0771f4c0ef57014df" ]
}

variable "ecr_image_url" {
  description = "URL da imagem do container no ECR"
  type        = string
  default     = "974090536112.dkr.ecr.us-east-1.amazonaws.com/ecs_calculadora_api:v1.0"
}

variable "service_name" {
  description = "Nome do serviço ECS"
  type        = string
  default     = "CalculadoraApiServices"
}

variable "container_port" {
  description = "Porta onde o container expõe o serviço"
  type        = number
  default     = 5010
}

variable "health_check_path" {
  description = "Caminho para o health check HTTP"
  type        = string
  default     = "/"
}
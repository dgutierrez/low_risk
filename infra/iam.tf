resource "aws_iam_role" "app_role" {
  name               = "${var.service_name}-role"
  assume_role_policy = data.aws_iam_policy_document.app_role_assume_role_policy.json
}

data "aws_iam_policy_document" "app_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }

    effect = "Allow"
  }
}

# assigns the app policy
resource "aws_iam_role_policy" "app_policy" {
  name   = "${var.service_name}-policy"
  role   = aws_iam_role.app_role.id
  policy = data.aws_iam_policy_document.app_policy.json
}

# TODO: fill out custom policy
data "aws_iam_policy_document" "app_policy" {
  statement {
    actions = [
        "ecr:GetAuthorizationToken",
        "ecs:DescribeClusters",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]

    effect = "Allow"

    resources = ["*"]
  }

  statement {
    sid = "AllowReadParameters"
    actions = [
      "secretmanager:GetSecretValue",
      "secretmanager:Describe",
      "secretmanager:List",
      "secretmanager:Get",
      "ssm:GetParameter"
    ]

    effect = "Allow"

    resources = ["*"]
  }

  statement {
    sid = "AllowKMS"
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ListKeyPolicies",
      "kms:ReEncrypt"
    ]

    effect = "Allow"

    resources = ["*"]
  }

  statement {
    sid = "AllowIam"
    actions = [
      "iam:GetRole",
      "iam:PassRole",
      "iam:CreateServiceLinkedRole",
      "iam:AttachRolePolicy",
      "iam:UpdateRoleDescription",
      "iam:DeleteServiceLinkedRole",
      "iam:GetServiceLinkedRoleDeletetionStatus",
      "lambda:InvokeFunction",
      "lambda:InvokeAsync"
    ]

    effect = "Allow"

    resources = ["*"]
  }

}


###### task role
resource "aws_iam_role" "ecs_task_role" {
  name = "Calculadora_ecs_task_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_ecs_cluster" "cluster" {
  name = "my-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = "my-cluster"
  }
}
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/app"
  retention_in_days = 7
}
resource "aws_ecs_task_definition" "task_def" {
  family                   = "my-task-def"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "my-container"
      image     = "767397770552.dkr.ecr.ap-south-1.amazonaws.com/ecs-devops-demo:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  tags = {
    Name = "my-app-task"
  }
}

resource "aws_ecs_service" "my_service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_def.arn
  desired_count   = 3
  launch_type     = "FARGATE"
  network_configuration {
    subnets = [
      aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id
    ]
    security_groups = [aws_security_group.ecs_sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.my_tg.arn
    container_name   = "my-container"
    container_port   = 5000
  }
  depends_on = [
    aws_lb_listener.my_listener
  ]
  tags = {
    Name = "app-service"
  }
}
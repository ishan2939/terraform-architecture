resource "aws_lb_target_group" "this" {
  count = var.create_tg ? 1 : 0

  name     = var.tg-name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }
}

resource "aws_lb_listener_rule" "backend_rule" {

  count = var.create_lr ? 1 : 0

  listener_arn = var.listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  condition {
    path_pattern {
      values = [var.path_pattern]
    }
  }
}


############################################################################
#                            Task Definition                               #                          
############################################################################

resource "aws_ecs_task_definition" "task_definition" {

  family                   = var.ecs_task_family
  execution_role_arn       = var.ecs_task_role_arn
  task_role_arn            = var.ecs_task_role_arn
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities

  cpu    = var.task_cpu
  memory = var.task_memory

  tags = {
    TerraformManaged = true
  }

  container_definitions = jsonencode([
    {
      "name" : "${var.ecs_container_name}",
      "image" : "${var.ecs_container_image}",
      "memoryReservation" : "${var.softLimit}", # number
      "cpu" : "${var.cpu}",
      "memory" : "${var.hardLimit}", # number
      "portMappings" : [
        {
          "containerPort" : "${var.containerPort}", #number
          "hostPort" : "${var.hostPort}",           #number
          "protocol" : "tcp",
          "name" : "${var.portName}"
        }
      ]
      "environment" : "${var.env_task_defintions}",
      "secrets" : "${var.secrets}"
      "logConfiguration" : {
        "logDriver" : "awslogs"
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "${var.ecs_awslogs_group}",
          "awslogs-region" : "${var.ecs_region}",
          "awslogs-stream-prefix" : "${var.ecs_awslogs_stream}"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  # depends_on = [aws_iam_role.ecs_task_role]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.ecs_awslogs_group
  retention_in_days = 7
}


############################################################################
#                              ECS Service                                 #                          
############################################################################

resource "aws_service_discovery_service" "this" {

  count = var.service_discovery ? 1 : 0
  name  = "service_discovery"

  dns_config {
    namespace_id = var.dns_namespace_id

    dns_records {
      ttl  = var.dns_ttl
      type = var.dns_type
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "ecs_service" {
  name                = var.ecs_service_name
  cluster             = var.ecs_service_cluster_id
  task_definition     = aws_ecs_task_definition.task_definition.arn
  desired_count       = var.desired_count # number
  scheduling_strategy = var.scheduling_strategy

  ordered_placement_strategy {
    field = "memory"
    type  = "binpack"
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  enable_ecs_managed_tags            = true
  health_check_grace_period_seconds = var.attach_load_balancer ? 180 : null
  # iam_role                           = var.ecs_service_role_arn


  dynamic "load_balancer" {
    for_each = var.attach_load_balancer ? [1] : []
    content {

      target_group_arn = aws_lb_target_group.this[0].arn
      container_name   = var.ecs_container_name
      container_port   = var.containerPort # number
    }
  }

  dynamic "service_registries" {
    for_each = var.service_discovery ? [1] : []
    content {
      container_port = var.containerPort
      registry_arn   = join(",", aws_service_discovery_service.this[*].arn)
      container_name = var.ecs_container_name
    }

  }

  dynamic "service_connect_configuration" {
    for_each = var.service_connect ? [1] : []
    content {
      enabled   = true
      namespace = var.dns_namespace_arn
    }

  }

  depends_on = [aws_ecs_task_definition.task_definition]

  tags = {
    TerraformManaged = true
  }
}





###############################################################################
#                              Codebuild                                      #
###############################################################################



resource "aws_iam_policy" "CodeBuildBasePolicy-policy-repo" {

  count       = var.create_codepipeline ? 1 : 0
  description = "Policy used in trust relationship with CodeBuild"
  name        = "CodeBuildBasePolicy-${var.codebuild_repo_policy_name}"
  path        = "/service-role/"

  policy = <<-EOF
    {
      "Statement": [
        {
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.codebuild_repo_project_name}",
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.codebuild_repo_project_name}:*"
          ]
        },
        {
          "Action": [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:s3:::${var.codebuild_codepipeline_artifact_store}",
            "arn:aws:s3:::${var.codebuild_codepipeline_artifact_store}/*"
          ]
        },
        {
          "Action": [
            "s3:PutObject",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:s3:::${var.codebuild_repo_artifacts_location}",
            "arn:aws:s3:::${var.codebuild_repo_artifacts_location}/*"
          ]
        },
        {
          "Action": [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases",
            "codebuild:BatchPutCodeCoverages"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report-group/${var.codebuild_repo_project_name}-*"
          ]
        }
      ],
      "Version": "2012-10-17"
    }
  EOF

  tags     = {}
  tags_all = {}
}

resource "aws_iam_role" "codebuild-service-role" {

  count              = var.create_codepipeline ? 1 : 0
  assume_role_policy = <<-EOF
    {
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
            "Service": "codebuild.amazonaws.com"
          }
        }
      ],
      "Version": "2012-10-17"
    }
  EOF

  force_detach_policies = false
  managed_policy_arns = [
    #    format("arn:aws:iam::%s:policy/service-role/CodeBuildBasePolicy-${var.bucket_name}", data.aws_caller_identity.current.account_id),
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/CloudFrontFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess"
  ]
  max_session_duration = 3600
  name                 = var.codebuild_repo_role_name
  path                 = "/service-role/"
  tags                 = {}
  tags_all             = {}
}

resource "aws_iam_policy_attachment" "attachment" {

  count = var.create_codepipeline ? 1 : 0

  name       = "CodeBuildBasePolicy-role-policy-attachment"
  roles      = [aws_iam_role.codebuild-service-role[0].name]
  policy_arn = aws_iam_policy.CodeBuildBasePolicy-policy-repo[0].arn
}

resource "aws_codebuild_project" "this" {

  count              = var.create_codepipeline ? 1 : 0
  name               = var.codebuild_repo_project_name
  description        = var.codebuild_repo_project_name
  service_role       = aws_iam_role.codebuild-service-role[0].arn
  source_version     = var.codebuild_repo_source_version
  badge_enabled      = true
  project_visibility = "PRIVATE"
  depends_on         = [aws_iam_role.codebuild-service-role[0]]

  source {
    buildspec           = var.buildspec_file_name
    git_clone_depth     = 1
    insecure_ssl        = false
    location            = var.codebuild_repo_source_location
    report_build_status = false
    type                = "GITHUB"

    git_submodules_config {
      fetch_submodules = true
    }
  }

  artifacts {
    encryption_disabled    = false
    location               = var.codebuild_repo_artifacts_location
    name                   = var.codebuild_repo_artifacts_name
    namespace_type         = "NONE"
    override_artifact_name = false
    packaging              = "ZIP"
    type                   = "S3"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"

    # environment_variable {
    #   name  = "AWS_DEFAULT_REGION"
    #   value = var.environment_variables["AWS_DEFAULT_REGION"]
    # }

    # environment_variable {
    #   name  = "AWS_ACCOUNT_ID"
    #   value = var.environment_variables["AWS_ACCOUNT_ID"]
    # }

    # environment_variable {
    #   name  = "IMAGE_REPO_NAME"
    #   value = var.environment_variables["IMAGE_REPO_NAME"]
    # }

    # environment_variable {
    #   name  = "IMAGE_TAG"
    #   value = var.environment_variables["IMAGE_TAG"]
    # }

    # environment_variable {
    #   name  = "CONTAINER_NAME"
    #   value = var.environment_variables["CONTAINER_NAME"]
    # }

    # environment_variable {
    #   name  = "PARAMETER_NAME"
    #   value = var.environment_variables["PARAMETER_NAME"]
    # }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }
}

resource "aws_cloudwatch_log_group" "cloudwatch" {

  count             = var.create_codepipeline ? 1 : 0
  name              = var.codebuild_repo_project_name
  retention_in_days = 7
  tags              = {}
  tags_all          = {}
}


# resource "aws_codebuild_webhook" "example" {
#   project_name = var.codebuild_repo_project_name

#   filter_group {
#     filter {
#       type    = "EVENT"
#       pattern = var.branch_event_type
#     }
#     filter {
#       type    = "HEAD_REF"
#       pattern = var.branch_head_ref
#       #    branch_filter = "develop"
#     }
#   }

#   depends_on = [aws_codebuild_project.this]

# }


###############################################################################
#                                Codepipeline v2                              #
###############################################################################


resource "aws_codepipeline" "this" {

  count      = var.create_codepipeline ? 1 : 0
  name       = var.codepipeline_name
  depends_on = [aws_iam_role.codepipeline-iam-role[0]]
  role_arn   = aws_iam_role.codepipeline-iam-role[0].arn
  tags       = {}
  tags_all   = {}

  pipeline_type = "V2"

  trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "Source"
      push {
        branches {
          includes = ["master"]
        }
      }
    }
  }

  artifact_store {
    location = var.codebuild_codepipeline_artifact_store
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      output_artifacts = ["SourceArtifact"]
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      run_order        = 1
      version          = "1"
      region = var.ecs_region
      configuration = {
        # OAuthToken = var.remote_repo_token
        # Owner      = var.remote_repo_owner
        # Repo       = var.remote_repo_name
        # Branch     = var.remote_branch

        ConnectionArn    = data.aws_codestarconnections_connection.connection.arn
        FullRepositoryId = var.remote_repo_name
        BranchName       = var.remote_branch
        # PollForSourceChanges = var.poll_source_changes
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 2
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.this[0].name # Mention secondary codebuild here
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "ClusterName"       = var.ecs_service_cluster_name
        # "DeploymentTimeout" = var.deployment_timeout
        "FileName"          = var.definition_file_name
        "ServiceName"       = var.ecs_service_name
      }
      input_artifacts = ["BuildArtifact"]
      name            = "Deploy"
      namespace       = "DeployVariables"
      owner           = "AWS"
      provider        = "ECS"
      region          = var.ecs_region
      run_order       = 3
      version         = "1"
    }
  }

}


resource "aws_iam_policy" "codepipeline-iam-policy" {

  count       = var.create_codepipeline ? 1 : 0
  description = "Policy used in trust relationship with CodePipeline"
  name        = var.codepipeline_policy_name
  path        = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "iam:PassRole",
          ]
          Condition = {
            StringEqualsIfExists = {
              "iam:PassedToService" = [
                "cloudformation.amazonaws.com",
                "elasticbeanstalk.amazonaws.com",
                "ec2.amazonaws.com",
                "ecs-tasks.amazonaws.com",
              ]
            }
          }
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Effect = "Allow",
          Action = "codestar-connections:UseConnection",
          "Resource" = "${data.aws_codestarconnections_connection.connection.arn}"
        },
        {
          Action = [
            "codecommit:CancelUploadArchive",
            "codecommit:GetBranch",
            "codecommit:GetCommit",
            "codecommit:GetRepository",
            "codecommit:GetUploadArchiveStatus",
            "codecommit:UploadArchive",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "codedeploy:CreateDeployment",
            "codedeploy:GetApplication",
            "codedeploy:GetApplicationRevision",
            "codedeploy:GetDeployment",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:RegisterApplicationRevision",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "codestar-connections:UseConnection",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "elasticbeanstalk:*",
            "ec2:*",
            "elasticloadbalancing:*",
            "autoscaling:*",
            "cloudwatch:*",
            "s3:*",
            "sns:*",
            "cloudformation:*",
            "rds:*",
            "sqs:*",
            "ecs:*",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "lambda:InvokeFunction",
            "lambda:ListFunctions",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "opsworks:CreateDeployment",
            "opsworks:DescribeApps",
            "opsworks:DescribeCommands",
            "opsworks:DescribeDeployments",
            "opsworks:DescribeInstances",
            "opsworks:DescribeStacks",
            "opsworks:UpdateApp",
            "opsworks:UpdateStack",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "cloudformation:CreateStack",
            "cloudformation:DeleteStack",
            "cloudformation:DescribeStacks",
            "cloudformation:UpdateStack",
            "cloudformation:CreateChangeSet",
            "cloudformation:DeleteChangeSet",
            "cloudformation:DescribeChangeSet",
            "cloudformation:ExecuteChangeSet",
            "cloudformation:SetStackPolicy",
            "cloudformation:ValidateTemplate",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild",
            "codebuild:BatchGetBuildBatches",
            "codebuild:StartBuildBatch",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "devicefarm:ListProjects",
            "devicefarm:ListDevicePools",
            "devicefarm:GetRun",
            "devicefarm:GetUpload",
            "devicefarm:CreateUpload",
            "devicefarm:ScheduleRun",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "servicecatalog:ListProvisioningArtifacts",
            "servicecatalog:CreateProvisioningArtifact",
            "servicecatalog:DescribeProvisioningArtifact",
            "servicecatalog:DeleteProvisioningArtifact",
            "servicecatalog:UpdateProduct",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "cloudformation:ValidateTemplate",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "ecr:DescribeImages",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "states:DescribeExecution",
            "states:DescribeStateMachine",
            "states:StartExecution",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "appconfig:StartDeployment",
            "appconfig:StopDeployment",
            "appconfig:GetDeployment",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags     = {}
  tags_all = {}
}


resource "aws_iam_role" "codepipeline-iam-role" {

  count = var.create_codepipeline ? 1 : 0
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codepipeline.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  managed_policy_arns = [
    #  format("arn:aws:iam::%s:policy/service-role/prev-mm-prod-policy", data.aws_caller_identity.current.account_id),
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
  ]
  max_session_duration = 3600
  name                 = var.codepipeline_role_name
  depends_on           = [aws_iam_policy.codepipeline-iam-policy[0]]
  path                 = "/service-role/"
  tags                 = {}
  tags_all             = {}
}

resource "aws_iam_policy_attachment" "attachment3" {

  count      = var.create_codepipeline ? 1 : 0
  name       = "CodePipeline-role-policy-attachment"
  roles      = [aws_iam_role.codepipeline-iam-role[0].name]
  policy_arn = aws_iam_policy.codepipeline-iam-policy[0].arn
}
# resource "aws_s3_bucket" "codepipeline_bucket" {
#   bucket = "codepipeline"

#   versioning {
#     enabled = true
#   }
# }

resource "aws_cloudwatch_log_group" "aws_codebuild_codepipeline-cloudwatch" {

  count             = var.create_codepipeline ? 1 : 0
  name              = var.codepipeline_name
  retention_in_days = 7
  tags              = {}
  tags_all          = {}
}

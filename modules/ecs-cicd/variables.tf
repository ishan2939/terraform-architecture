variable "ecs_task_role" {
  type = string
}

variable "ecs_service_role" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "ecs_service_role_arn" {
  type = string
}

# variable "target_group_arn" {
#   type = string
# }

###############################################################################
#                              Load balncing                                  #
###############################################################################



variable "tg-name" {
  type    = string
  default = "aws-target-group"
}

variable "create_tg" {
  type    = bool
  default = false
}

variable "create_ls" {
  type    = bool
  default = false
}

variable "create_lr" {
  type    = bool
  default = false
}

variable "load_balancer_arn" {
  type    = string
}

variable "listener_arn" {
  type    = string
}

variable "listener_rule_priority" {
  type    = number
  default = 10
}

variable "path_pattern" {
  type    = string
  default = "/api*"
}

variable "host_header" {
  type    = string
  default = "example-site.com"
}

variable "health_check_path" {
  type    = string
  default = "/health-check"
}

variable "health_check_interval" {
  type    = number
  default = 30
}

variable "health_check_timeout" {
  type    = number
  default = 10
}

variable "healthy_threshold" {
  type    = number
  default = 3
}

variable "unhealthy_threshold" {
  type    = number
  default = 3
}


###############################################################################
#                              ECS Service                                    #
###############################################################################



variable "ecs_task_family" {
  type = string

}


variable "network_mode" {
  type = string

}

variable "requires_compatibilities" {
  type = list(string)
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "cpu" {
  type    = number
  default = 256
}

variable "softLimit" {
  type    = number
  default = 256
}

variable "hardLimit" {
  type    = number
  default = 512
}

variable "ecs_container_image" {
  type = string

}

variable "containerPort" {
  type    = number
  default = 8080
}

variable "hostPort" {
  type    = number
  default = 0
}

variable "portName" {
  type    = string
  default = "port name"
}

variable "ecs_awslogs_group" {
  type    = string
  default = "ecs-logs-group-1"
}

variable "ecs_region" {
  type = string
}

variable "ecs_awslogs_stream" {
  type    = string
  default = "ecs-logs-stream-1"
}

variable "ecs_service_name" {
  type = string

}

variable "ecs_service_cluster_id" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "scheduling_strategy" {
  type    = string
  default = "REPLICA"
}

variable "awslogs_region" {
  type = string
}

variable "ecs_container_name" {
  type = string

}

variable "vpc_id" {
  type = string
}

variable "attach_load_balancer" {
  type    = bool
  default = false
}

variable "dns_ttl" {
  type    = number
  default = 60
}

variable "dns_type" {
  type    = string
  default = "SRV"
}


variable "service_discovery" {
  type    = bool
  default = false
}

variable "service_connect" {
  type    = bool
  default = false
}

variable "dns_namespace_arn" {
  type = string
}

variable "dns_namespace_id" {
  type = string
}

variable "env_task_defintions" {
  type = list(object({
    name  = string
    value = string
  }))
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
}

# variable "listener_arn" {
#   type = string
# }

variable "create_codepipeline" {
  type = bool
  default = false
}


###############################################################################
#                                  Codebuild                                  #
###############################################################################


variable "codebuild_repo_policy_name" {
  type = string
  default = "aws-codebuild-repo-policy"
}

variable "codebuild_codepipeline_artifact_store" {
  type = string
  default = ""
}

variable "codebuild_repo_artifacts_location" {
  type = string
  
}

variable "codebuild_repo_role_name" {
  type = string
  default = "aws-codebuild-repo-role"
}

variable "codebuild_repo_project_name" {
  type = string
  
}

variable "codebuild_repo_source_version" {
  type = string
 
}

variable "codebuild_repo_source_location" {
  type = string
  
}

variable "codebuild_repo_artifacts_name" {
  type = string
  default = "aws-repo-artifacts"
}

variable "branch_event_type" {
  type = string
  default = "PUSH, PULL_REQUEST_MERGED"
}

variable "branch_head_ref" {
  type = string
  default = "refs/heads/branch_name"
}

variable "buildspec_file_name" {
  type = string
  default = "buildspec_backend.yml"
}

###############################################################################
#                                 Deploy                                      #
###############################################################################



# variable "ecs_listener_arns" {
#   type = string
# }

variable "ecs_service_cluster_name" {
  type = string
}

variable "deployment_timeout" {
  type = number
  default = 8
}



###############################################################################
#                              Codepipeline                                   #
###############################################################################


variable "codepipeline_name" {
  type = string
  default = "aws-codepipeline-name"
}

variable "codepipeline_policy_name" {
  type = string
  default = "aws-codepipeline-policy"
}

variable "codepipeline_role_name" {
  type = string
  default = "aws-codepipeline-role"
}

variable "remote_party_owner" {
  type = string
  default = "ThirdParty"
}

variable "source_version_provider" {
  type = string
  default = "GitHub"
}


variable "remote_repo_token" {
  description = "OAuth token for the remote repository"
  type        = string
  default = "remote-repo-oauth-token"
}

variable "remote_repo_owner" {
  description = "Owner of the remote repository"
  type        = string
  default = "remote-repo-owner"
}

variable "remote_repo_name" {
  description = "Name of the remote repository"
  type        = string
  
}

variable "remote_branch" {
  description = "Branch of the remote repository"
  type        = string
  default = "main"
}

variable "poll_source_changes" {
  description = "Flag to determine if polling for source changes should be enabled"
  type        = bool
  default = false
}

variable "definition_file_name" {
  description = "Image definition file name"
  type        = string
  default = "imagedefinition.json"
}
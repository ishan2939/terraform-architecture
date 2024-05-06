module "vpc" {
  source = "../modules/networking/vpc"

  cidr_block = var.cidr_block

  vpc-name   = var.vpc-name
  tags       = var.tags
  extra_tags = var.extra_tags
}

module "pub-sub" {
  source   = "../modules/networking/subnet"
  for_each = { for pub_subnets in flatten(local.pub_subnets) : pub_subnets.cidr_block => pub_subnets }

  subnet-name       = each.value.subnet_name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  vpc_id = module.vpc.vpc_id

  tags       = local.tags
  extra_tags = local.extra_tags
}

module "pvt-sub" {
  source   = "../modules/networking/subnet"
  for_each = { for pvt_subnets in flatten(local.pvt_subnets) : pvt_subnets.cidr_block => pvt_subnets }

  subnet-name       = each.value.subnet_name
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  vpc_id = module.vpc.vpc_id

  tags       = local.tags
  extra_tags = local.extra_tags
}

module "internet_gateway" {
  source = "../modules/networking/internet-gateway"

  ig-name = var.ig-name
  vpc_id  = module.vpc.vpc_id

  tags       = var.tags
  extra_tags = var.extra_tags
}

module "eip" {
  source = "../modules/networking/elastic-ip"

  for_each = { for e_ips in flatten(local.elastic_ips) : e_ips.ip_name => e_ips }

  eip-name   = each.value.ip_name
  tags       = var.tags
  extra_tags = var.extra_tags
}

module "natgw" {
  source = "../modules/networking/nat-gateway"

  for_each = { for idx, e_ips in flatten(local.nt_gateway) : idx => e_ips }

  ng-name       = each.value.ng-name
  allocation_id = local.epi_ids[each.key]
  subnet_id     = local.pub_subnet_ids[each.key]

  tags       = var.tags
  extra_tags = var.extra_tags
}

module "pub_route_table" {
  source = "../modules/networking/route-table-public"

  for_each = { for idx, pub_rt in flatten(local.pub_route_tables) : idx => pub_rt }

  rt-name     = each.value.rt-name
  vpc_id      = module.vpc.vpc_id
  igateway_id = module.internet_gateway.igw_id

  subnet_id = local.pub_subnet_ids[each.key]

  tags = var.tags
}

module "pvt_route_table" {
  source = "../modules/networking/route-table-private"

  for_each = { for idx, pvt_rt in flatten(local.pvt_route_tables) : idx => pvt_rt }

  rt-name        = each.value.rt-name
  vpc_id         = module.vpc.vpc_id
  nat_gateway_id = module.natgw[each.key].natgw_id


  subnet_id = local.pvt_subnet_ids[each.key]

  tags = var.tags
}

module "ecs" {
  source = "../modules/ecs"

  cluster_name      = var.ecs_cluster_name
  capacity_provider = var.capacity_provider_name
  #ecs_asg_arn 
  maximum_scaling_step_size     = var.max_scaling_step_size
  launch_template_name          = var.ecs_template_name
  launch_template_instance_type = var.ecs_instance_type
  ebs_volume_size               = var.ecs_volume_size          // number
  ebs_volume_type               = var.ecs_instance_volume_type //gp3
  enable_encryption             = true
  tag_value                     = var.ecs_tag_value
  asg_name                      = var.ecs_asg_name
  security_group_ids            = [module.security_group["sg1"].sg_id]
  # ecs_instance_profile_role = "ecsInstanceRole"
  min_size               = var.ecs_asg_min_size     // number
  max_size               = var.ecs_asg_max_size     // number
  desired_capacity       = var.ecs_asg_desired_size // number
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = local.pvt_subnet_ids
  on_demand_capacity     = var.ecs_on_demand_cap
  ecs_instance_role_name = var.ecs_instance_role_name
  instance_profile       = var.ecs_instance_profile_name
  spot_max_price         = var.spot_max_price
  key_name               = var.ecs_instance_ssh_name // Please create this before assigning
  user_data_script       = local.encoded_userdata
}

module "security_group" {
  source        = "../modules/networking/security-groups"
  for_each      = var.security_groups
  sg_name       = each.value.name
  vpc_id        = module.vpc.vpc_id
  ingress_rules = each.value.ingress_rules
  egress_rules  = each.value.egress_rules
}

module "load_balancer" {
  source              = "../modules/networking/alb"
  alb_name            = var.alb_name
  is_internal         = var.is_internal
  alb_security_groups = [module.security_group["sg1"].sg_id]
  alb_subnets         = local.pub_subnet_ids
  default_tg_name     = var.default_tg_name
  vpc_id              = module.vpc.vpc_id
  # certificate_arn     = data.aws_acm_certificate.certificate_arn.arn
}

resource "aws_iam_role" "ecs_task_role" {
  name = var.ecs_task_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
      },
    ],
  })

  managed_policy_arns = [
    #    format("arn:aws:iam::%s:policy/service-role/CodeBuildBasePolicy-${var.codebuild_s3_bucket_name}-eu-north-1", data.aws_caller_identity.current.account_id),
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"


    # "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    # "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    # "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    # "arn:aws:iam::aws:policy/CloudFrontFullAccess",
    # "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    # "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  ]
}


resource "aws_iam_role" "ecs_service_role" {
  name = var.ecs_service_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs.amazonaws.com"
        },
      },
    ],
  })

  # managed_policy_arns = [
  #   "arn:aws:iam::aws:policy/aws-service-role/AmazonECSServiceRolePolicy"
  # ]
}

resource "aws_service_discovery_private_dns_namespace" "private" {
  name        = "private_dns_namespace"
  description = "Private dns namespace for service discovery"
  vpc         = module.vpc.vpc_id
}

module "s3" {
  source             = "../modules/s3"
  for_each           = var.s3_bucket
  bucket             = each.value.bucket
  bucket_environment = each.value.bucket_environment
  bucket_versioning  = each.value.bucket_versioning
}


module "ecs_infrastructure" {
  source = "../modules/ecs-cicd" # Replace with the correct path

  depends_on = [aws_iam_role.ecs_task_role, aws_iam_role.ecs_service_role]
  for_each   = var.ecs_service

  ecs_task_role    = each.value.ecs_task_role
  ecs_service_role = each.value.ecs_service_role

  ecs_task_role_arn    = aws_iam_role.ecs_task_role.arn
  ecs_service_role_arn = aws_iam_role.ecs_service_role.arn
  # target_group_arn     = module.load_balancer.this[each.value.target_group_name]

  # target_group_name              = each.value.target_group_name
  listener_rule_priority = each.value.listener_rule_priority
  path_pattern           = each.value.path_pattern
  host_header            = each.value.host_header
  health_check_path      = each.value.health_check_path
  health_check_interval  = each.value.health_check_interval
  health_check_timeout   = each.value.health_check_timeout
  healthy_threshold      = each.value.healthy_threshold
  unhealthy_threshold    = each.value.unhealthy_threshold

  attach_load_balancer = each.value.attach_load_balancer
  dns_ttl              = each.value.dns_ttl
  dns_type             = each.value.dns_type
  service_discovery    = each.value.service_discovery
  service_connect      = each.value.service_connect

  ecs_task_family          = each.value.ecs_task_family
  network_mode             = each.value.network_mode
  requires_compatibilities = each.value.requires_compatibilities
  cpu                      = each.value.cpu
  task_cpu                 = each.value.task_cpu
  task_memory              = each.value.task_memory
  softLimit                = each.value.softLimit
  hardLimit                = each.value.hardLimit
  ecs_container_image      = each.value.ecs_container_image
  containerPort            = each.value.containerPort
  hostPort                 = each.value.hostPort
  portName                 = each.value.portName
  ecs_awslogs_group        = each.value.ecs_awslogs_group
  ecs_region               = data.aws_region.current.name
  ecs_awslogs_stream       = each.value.ecs_awslogs_stream
  ecs_service_name         = each.value.ecs_service_name
  ecs_service_cluster_id   = module.ecs.cluster_id
  desired_count            = each.value.desired_count
  scheduling_strategy      = each.value.scheduling_strategy
  awslogs_region           = data.aws_region.current.name
  ecs_container_name       = each.value.ecs_container_name
  vpc_id                   = module.vpc.vpc_id

  ecs_service_cluster_name = each.value.ecs_service_cluster_name

  dns_namespace_arn = aws_service_discovery_private_dns_namespace.private.arn
  dns_namespace_id  = aws_service_discovery_private_dns_namespace.private.id

  env_task_defintions = each.value.env_task_defintions

  secrets = each.value.secrets

  create_tg         = each.value.create_tg
  listener_arn      = module.load_balancer.http_listner_arn
  create_lr         = each.value.create_lr
  load_balancer_arn = module.load_balancer.alb_arn
  tg-name           = each.value.tg-name

  create_codepipeline = each.value.create_codepipeline

  buildspec_file_name                   = each.value.buildspec_file_name
  codebuild_repo_policy_name            = each.value.codebuild_repo_policy_name
  codebuild_codepipeline_artifact_store = module.s3["bucket1"].s3_name # name of s3 bucket object
  codebuild_repo_artifacts_location     = module.s3["bucket1"].s3_name # name of s3 bucket object for codebuild
  codebuild_repo_role_name              = each.value.codebuild_repo_role_name
  codebuild_repo_project_name           = each.value.codebuild_repo_project_name
  codebuild_repo_source_version         = each.value.codebuild_repo_source_version
  codebuild_repo_source_location        = each.value.codebuild_repo_source_location
  codebuild_repo_artifacts_name         = each.value.codebuild_repo_artifacts_name
  branch_event_type                     = each.value.branch_event_type
  branch_head_ref                       = each.value.branch_head_ref

  # ecs_listener_arns              = module.load_balancer.http_listner        # replace with https_listner when SSL available
  # ecs_service_cluster_name       = module.ecs.cluster_name

  codepipeline_name        = each.value.codepipeline_name
  codepipeline_policy_name = each.value.codepipeline_policy_name
  codepipeline_role_name   = each.value.codepipeline_role_name

  remote_party_owner      = each.value.remote_party_owner
  source_version_provider = each.value.source_version_provider
  remote_repo_token       = each.value.remote_repo_token
  remote_repo_owner       = each.value.remote_repo_owner
  remote_repo_name        = each.value.remote_repo_name
  remote_branch           = each.value.remote_branch
  poll_source_changes     = each.value.poll_source_changes
  deployment_timeout      = each.value.deployment_timeout
  definition_file_name    = each.value.definition_file_name
}

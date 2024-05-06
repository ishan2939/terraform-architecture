locals {

  pvt_subnets = flatten([
    {
      subnet_name       = "${terraform.workspace}-pvt-sub-1"
      cidr_block        = "172.31.0.0/24"
      availability_zone = "us-east-1a"
    },
    {
      subnet_name       = "${terraform.workspace}-pvt-sub-2"
      cidr_block        = "172.31.6.0/24"
      availability_zone = "us-east-1d"
    }
  ])

  pub_subnets = flatten([
    {
      subnet_name       = "${terraform.workspace}-pub-sub-1"
      cidr_block        = "172.31.1.0/24"
      availability_zone = "us-east-1a"
    },
    {
      subnet_name       = "${terraform.workspace}-pub-sub-2"
      cidr_block        = "172.31.7.0/24"
      availability_zone = "us-east-1d"
    }
  ])

  pub_route_tables = flatten([
    {
      rt-name : "${terraform.workspace}-pub_rt_1"
    },
    {
      rt-name : "${terraform.workspace}-pub_rt_2"
    }
  ])

  pvt_route_tables = flatten([
    {
      rt-name : "${terraform.workspace}-pvt_rt_1"
    },
    {
      rt-name : "${terraform.workspace}-pvt_rt_2"
    }
  ])

  elastic_ips = flatten([
    {
      ip_name : "${terraform.workspace}-ep-1"
    },
    {
      ip_name : "${terraform.workspace}-ep-2"
    }
  ])

  nt_gateway = flatten([
    {
      ng-name : "${terraform.workspace}-NAT-gateway-1"
    },
    {
      ng-name : "${terraform.workspace}-NAT-gateway-2"
    }
  ])

  pub_subnet_ids = flatten([
    for subnet in module.pub-sub : subnet.id
  ])

  pvt_subnet_ids = flatten([
    for subnet in module.pvt-sub : subnet.id
  ])

  epi_ids = flatten([
    for epi in module.eip : epi.eip_id
  ])

  # service_ids = flatten([
  #   for service in module.ecs_infrastructure : service.service_ids
  # ])

  task_definition_arns = flatten([
    for task_definition in module.ecs_infrastructure : task_definition.task_definition_arns
  ])

  tags = {
    environment = "${terraform.workspace}"
    project     = "My-terraform-project"
  }

  extra_tags = {}

  userdata_script = <<-EOT
    #!/bin/bash
    echo ECS_CLUSTER=My-Todo-Cluster-Terraform-${terraform.workspace} >> /etc/ecs/ecs.config
  EOT

  encoded_userdata = base64encode(local.userdata_script)

  service2_info = module.ecs_infrastructure

}

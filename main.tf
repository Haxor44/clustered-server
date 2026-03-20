/* This is a simple Terraform configuration file that creates an EC2 instance in AWS. */
/* The terraform block is used to specify the required providers and their versions. */
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

/* This tells Terraform that you are going to be using AWS as your provider and that
   you want to deploy your infrastructure into the us-east-2 region.
*/
provider "aws" {
  region = var.variable_region
}

# We create the VPC to launch our instances in
data "aws_vpc" "default" {
    default = true
}

# Terraform Data Block - Lookup Ubuntu 22.04
data "aws_ami" "ubuntu_22_04" {
  most_recent = true

  filter {
    name   = var.variable_data_filter_name
    values = var.variable_data_filter_values
  }

  owners = var.variable_data_owner
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}



resource "aws_launch_template" "web" {
    name = var.variable_launch_template_name
    image_id = data.aws_ami.ubuntu_22_04.id
    instance_type = var.variable_instance_type
    network_interfaces {
      security_groups = [aws_security_group.web-sg.id]
    }
    user_data = base64encode(<<-EOF
                #!/bin/bash
                echo "WELCOME TO THE WEB SERVER" > index.html
                nohup busybox httpd -f -p ${var.variable_server_port} &
                EOF
    )
    lifecycle {
      create_before_destroy = true
    }
}

# We create the auto scaling group to automatically scale our instances based on demand
resource "aws_autoscaling_group" "web-asg" {
    /* The launch template parameter specifies the launch template that will be used to launch the instances in the auto scaling group. */
    launch_template {
      id = aws_launch_template.web.id
      version = var.variable_asg_lt_version
    }
    /* The min_size and max_size parameters specify the minimum and maximum number of instances that the auto scaling group should maintain. */
    min_size = var.variable_min_size
    max_size = var.variable_max_size
    /* The vpc_zone_identifier parameter is used to specify the subnets that the auto scaling
         group should use to launch the instances. */
    vpc_zone_identifier = data.aws_subnets.default.ids
    /* The target_group_arns parameter is used to specify the target groups that the auto scaling group should register the instances with. */
    target_group_arns = [aws_lb_target_group.web-tg.arn]
    health_check_type = var.variable_asg_health_check_type
}

# We create the load balancer to distribute traffic to our instances in the auto scaling group
resource "aws_lb" "web-lb"{
    name = var.variable_lb_name
    load_balancer_type = var.variable_lb_type
    subnets = data.aws_subnets.default.ids
    security_groups = [aws_security_group.alb-sg.id]
}

# We create the load balancer listener to listen for incoming traffic on the specified port and protocol
resource "aws_lb_listener" "web-lb-listener"{
    load_balancer_arn = aws_lb.web-lb.arn
    port = var.variable_lb_listener_port
    protocol = var.variable_lb_listener_protocol
    default_action {
      type = var.variable_lb_da_type

      fixed_response {
        content_type = var.variable_lb_da_fixed_response_content_type
        message_body = var.variable_lb_da_fixed_response_message_body
        status_code = var.variable_lb_da_fixed_response_code
      }
    }
}

# We create the security group for the load balancer to allow traffic from the internet and to the instances in the auto scaling group
resource "aws_security_group" "alb-sg"{
    name = var.variable_alb_sg_name
    description = "Allow HTTP traffic on port 80"

    # Allow inbound HTTP requests
    ingress {
        from_port = var.variable_lb_listener_port
        to_port = var.variable_lb_listener_port
        protocol = var.variable_sg_protocol
        cidr_blocks = var.varibale_sg_cidr_block
    }
    # Allow outbound traffic to the instances in the auto scaling group
    egress {
        from_port = var.variable_alb_sg_egress_port
        to_port = var.variable_alb_sg_egress_port
        protocol = var.variable_alb_sg_egress_protocol
        cidr_blocks = var.varibale_sg_cidr_block
    }

}


/*We create the security group so as to allow traffic to our server from the internet*/
resource "aws_security_group" "web-sg"{
    name = var.variable_security_group_name
    description = "Allow HTTP traffic on port 8080"

    ingress {
        from_port = var.variable_server_port
        to_port = var.variable_server_port
        protocol = var.variable_sg_protocol
        cidr_blocks = var.varibale_sg_cidr_block
    }
}

# We create the target group to register our instances in the auto scaling group with the load balancer
resource "aws_lb_target_group" "web-tg"{
    name = var.variable_lb_tg_name
    port = var.variable_server_port
    protocol = var.variable_lb_listener_protocol
    vpc_id = data.aws_vpc.default.id

    # This target group will health check your Instances by periodically sending an HTTP request to each Instance and will consider the Instance “healthy” only if the Instance returns a response that matches the configured matcher
    health_check {
      path = var.variable_alb_tg_health_check.path
      protocol = var.variable_alb_tg_health_check.protocol
      matcher = var.variable_alb_tg_health_check.matcher
      interval = var.variable_alb_tg_health_check.interval
      timeout = var.variable_alb_tg_health_check.timeout
      healthy_threshold = var.variable_alb_tg_health_check.healthy_threshold
      unhealthy_threshold = var.variable_alb_tg_health_check.unhealthy_threshold

    }
}

resource "aws_lb_listener_rule" "web-lb-listener-rule"{
    listener_arn = aws_lb_listener.web-lb-listener.arn
    priority = var.variable_lb_listener_rule_priority

    action {
        type = var.variable_lb_listener_rule_action_type
        target_group_arn = aws_lb_target_group.web-tg.arn
    }

    condition {
        path_pattern {
            values = var.variable_lb_listener_rule_condition_path_pattern_values
        }
    }
}
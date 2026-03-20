variable "variable_instance_type" {
  
    description = "The type of ec2 instance"
    type = string
    default = "t2.micro"
}

variable "variable_region" {
    description = "Where our servers will be deployed"
    type = string
    default = "us-east-2"
}

variable "variable_user_data_bool"{
    description = "This specifies whether to use data or not"
    type =  bool
    default = true
}

variable "variable_launch_template_name" {
  description = "Name for the launch template"
  type = string
  default = "web-launch"
}

variable "variable_asg_lt_version" {
  description = "Version of the launch template to be used in the auto scaling group"
  type = string
  default = "$Latest"
}
variable "variable_security_group_name"{
    description = "The name of the security group"
    type = string
    default = "web-sg"
}

variable "varibale_sg_cidr_block"{
    description = "The cidr block for the security group"
    type = list(string)
    default = [ "0.0.0.0/0" ]
}

variable "variable_sg_protocol" {
  description = "The protocol allowed in the sg ingress rules"
  type = string
  default = "tcp"
}

variable "variable_data_filter_name" {
  description = "value for the filter in data source fro ami lookup"
  type = string
  default = "name"
}

variable "variable_data_filter_values" {
  description = "values for the filter in data source for ami lookup"
  type = list(string)
  default = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  
}

variable "variable_data_owner" {
  description = "value for the owners in data source ami lookup"
  type = list(string)
  default = [ "099720109477" ]
}


variable "variable_min_size" {
  description = "The minimum number of instances to launch in the auto scaling group"
  type = number
  default = 2
}

variable "variable_max_size" {
  description = "The maximum number of instances to launch in the auto scaling group"
  type = number
  default = 5
}

variable "variable_asg_health_check_type" {
  description = "The type of health check to be performed on the instances in the auto scaling group"
  type = string
  default = "ELB"
}

variable "variable_lb_name" {
  description = "The name of the load balancer"
  type = string
  default = "web-lb"
}

variable "variable_lb_type" {
  description = "The type of the load balancer"
  type = string
  default = "application"
}

variable "variable_lb_listener_port"{
    description = "The value of the port for which lb will listen on"
    type =  number
    default = 80
}

variable "variable_lb_listener_protocol" {
  description = "Protocol used by the lb listener"
  type = string
  default = "HTTP"
}

variable "variable_lb_listener_rule_priority" {
    description = "Priority for the listener group"
    type = number
    default = 100
}

variable "variable_lb_listener_rule_action_type" {
  description = "The type of action for the listener rule"
  type = string
  default = "forward"
}

variable "variable_lb_listener_rule_action_target_group_arn" {
  description = "The ARN of the target group for the listener rule"
  type = string
  default = "aws_lb_target_group.web-tg.arn"
}

variable "variable_lb_listener_rule_condition_path_pattern_values" {
  description = "Values for the path pattern condition in the listener rule"
  type = list(string)
  default = [ "*" ] 
}

variable "variable_lb_da_type" {
  description = "The type of the default action for the lb listener"
  type = string
  default = "fixed-response"
}

variable "variable_lb_da_fixed_response_code" {
  description = "The status code for the fixed response default action of the lb listener"
  type = number
  default = 200
}

variable "variable_lb_da_fixed_response_content_type" {
  description = "The content type for the fixed response default action of the lb listener"
  type = string
  default = "text/plain"
}

variable "variable_lb_da_fixed_response_message_body" {
  description = "The message body for the fixed response default action of the lb listener"
  type = string
  default = "Welcome to the web servers"
}

variable "variable_alb_sg_name" {
  description = "The name of the security group for the application load balancer"
  type = string
  default = "alb-sg"
}


variable "variable_server_port"{
    description = "The port on which our server will be running"
    type = number
    default = 8080
}

variable "variable_alb_sg_egress_port"{
    description = "Outbound port for the security group of the application load balancer"
    type = number
    default = 0
}

variable "variable_alb_sg_egress_protocol"{
    description = "Outbound protocol for the security group of the application load balancer"
    type = string
    default = "-1"
}

variable "variable_lb_tg_name" {
  description = "The name of the load balancer target group"
  type = string
  default = "web-tg"
}


variable "variable_alb_tg_health_check"{
    description = "Health checks to be performed on target gorup servers"
    type = object({
      path  = string
      protocol = string
      matcher = string
      interval = number
      timeout = number
      healthy_threshold = number 
      unhealthy_threshold = number
    })
    default = {
      path = "/"
      protocol = "HTTP"
      matcher = "200"
      interval = 15
      timeout = 3
      healthy_threshold = 2
      unhealthy_threshold = 2
    }
}

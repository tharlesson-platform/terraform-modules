variable "region" {
  description = "AWS region."
  type        = string
}

variable "aws_profile" {
  description = "Optional AWS CLI profile."
  type        = string
  default     = null
}

variable "aws_assume_role_arn" {
  description = "Optional IAM Role ARN to assume in target AWS account."
  type        = string
  default     = null
}

variable "aws_assume_role_session_name" {
  description = "Session name used when assuming role."
  type        = string
  default     = "terraform-ec2-autoscaling"
}

variable "client" {
  description = "Client identifier for naming and tags."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prod)."
  type        = string
}

variable "workload_name" {
  description = "Workload suffix used in resource naming."
  type        = string
  default     = "app"
}

variable "instance_name" {
  description = "Optional explicit Name tag propagated to launched instances."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "subnet_ids" {
  description = "Optional explicit subnet IDs for ASG. Leave empty to auto-discover private subnets."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID used to discover private subnets and create security group."
  type        = string
  default     = null
}

variable "private_subnet_tag_key" {
  description = "Tag key used to discover private subnets."
  type        = string
  default     = "Tier"
}

variable "private_subnet_tag_values" {
  description = "Tag values used to discover private subnets."
  type        = list(string)
  default     = ["private"]
}

variable "ami_id" {
  description = "Optional explicit AMI ID."
  type        = string
  default     = null
}

variable "resolve_ami_from_ssm" {
  description = "Resolve AMI from SSM parameter when ami_id is null."
  type        = bool
  default     = true
}

variable "ami_ssm_parameter_name" {
  description = "SSM parameter name used to resolve AMI."
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

variable "key_name" {
  description = "Existing key pair name used by launch template."
  type        = string
  default     = null
}

variable "ebs_optimized" {
  description = "Enable EBS optimization."
  type        = bool
  default     = null
}

variable "detailed_monitoring" {
  description = "Enable detailed monitoring for launched instances."
  type        = bool
  default     = true
}

variable "user_data" {
  description = "Plain-text user data script."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Base64-encoded user data content."
  type        = string
  default     = null
}

variable "create_security_group" {
  description = "Create dedicated security group for ASG instances."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Optional explicit security group name."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "Existing security groups attached to instances."
  type        = list(string)
  default     = []
}

variable "security_group_ingress_rules" {
  description = "Ingress rules for created security group."
  type = list(object({
    description                  = optional(string)
    ip_protocol                  = string
    from_port                    = optional(number)
    to_port                      = optional(number)
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
  }))
  default = []
}

variable "security_group_egress_rules" {
  description = "Optional custom egress rules for created security group."
  type = list(object({
    description                  = optional(string)
    ip_protocol                  = string
    from_port                    = optional(number)
    to_port                      = optional(number)
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
  }))
  default = []
}

variable "create_instance_profile" {
  description = "Create IAM role + instance profile in this stack."
  type        = bool
  default     = true
}

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile name when create_instance_profile is false."
  type        = string
  default     = null
}

variable "instance_profile_name" {
  description = "Optional explicit instance profile name when created in this stack."
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Optional explicit IAM role name when created in this stack."
  type        = string
  default     = null
}

variable "iam_role_policy_arns" {
  description = "Managed policy ARNs attached to created IAM role."
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

variable "root_block_device" {
  description = "Optional root block device settings for launch template."
  type = object({
    volume_type           = optional(string)
    volume_size           = optional(number)
    iops                  = optional(number)
    throughput            = optional(number)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string)
    delete_on_termination = optional(bool, true)
  })
  default = null
}

variable "ebs_block_devices" {
  description = "Additional EBS block device mappings for launch template."
  type = list(object({
    device_name           = string
    no_device             = optional(string)
    virtual_name          = optional(string)
    volume_size           = optional(number)
    volume_type           = optional(string)
    iops                  = optional(number)
    throughput            = optional(number)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string)
    snapshot_id           = optional(string)
    delete_on_termination = optional(bool, true)
  }))
  default = []
}

variable "min_size" {
  description = "Minimum ASG capacity."
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "Desired ASG capacity."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum ASG capacity."
  type        = number
  default     = 2
}

variable "health_check_type" {
  description = "ASG health check type."
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "ASG health check grace period (seconds)."
  type        = number
  default     = 300
}

variable "default_cooldown" {
  description = "ASG default cooldown (seconds)."
  type        = number
  default     = 300
}

variable "target_group_arns" {
  description = "Optional ALB/NLB target groups attached to ASG."
  type        = list(string)
  default     = []
}

variable "termination_policies" {
  description = "Optional ASG termination policies."
  type        = list(string)
  default     = []
}

variable "protect_from_scale_in" {
  description = "Enable instance protection from scale-in."
  type        = bool
  default     = false
}

variable "wait_for_capacity_timeout" {
  description = "Terraform timeout waiting for ASG capacity."
  type        = string
  default     = "10m"
}

variable "force_delete" {
  description = "Allow force deletion of ASG."
  type        = bool
  default     = false
}

variable "capacity_rebalance" {
  description = "Enable ASG capacity rebalance."
  type        = bool
  default     = false
}

variable "max_instance_lifetime" {
  description = "Maximum instance lifetime in ASG (seconds)."
  type        = number
  default     = null
}

variable "enabled_metrics" {
  description = "ASG metrics enabled in CloudWatch."
  type        = list(string)
  default     = []
}

variable "metrics_granularity" {
  description = "Granularity for enabled ASG metrics."
  type        = string
  default     = "1Minute"
}

variable "cpu_target_tracking_enabled" {
  description = "Enable built-in CPU target tracking policy."
  type        = bool
  default     = true
}

variable "cpu_target_tracking_target_value" {
  description = "Target CPU value for built-in target tracking policy."
  type        = number
  default     = 60
}

variable "cpu_target_tracking_disable_scale_in" {
  description = "Disable scale-in for built-in CPU target tracking policy."
  type        = bool
  default     = false
}

variable "cpu_target_tracking_estimated_instance_warmup" {
  description = "Estimated instance warmup (seconds) for CPU target tracking policy."
  type        = number
  default     = 180
}

variable "target_tracking_policies" {
  description = "Additional target tracking policies."
  type = list(object({
    name                      = string
    target_value              = number
    disable_scale_in          = optional(bool, false)
    estimated_instance_warmup = optional(number)
    predefined_metric_type    = optional(string, "ASGAverageCPUUtilization")
    resource_label            = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}

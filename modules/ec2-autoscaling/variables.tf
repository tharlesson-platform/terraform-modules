variable "name" {
  description = "Base name used for Auto Scaling resources."
  type        = string
}

variable "instance_name" {
  description = "Optional explicit Name tag propagated to instances. Defaults to name."
  type        = string
  default     = null
}

variable "launch_template_name" {
  description = "Optional explicit launch template name."
  type        = string
  default     = null
}

variable "autoscaling_group_name" {
  description = "Optional explicit Auto Scaling Group name."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type used by launch template."
  type        = string
}

variable "ami_id" {
  description = "Optional explicit AMI ID. If null and resolve_ami_from_ssm=true, AMI will be resolved from SSM."
  type        = string
  default     = null
}

variable "resolve_ami_from_ssm" {
  description = "Resolve AMI from SSM parameter when ami_id is null."
  type        = bool
  default     = true
}

variable "ami_ssm_parameter_name" {
  description = "SSM parameter name used to resolve AMI when resolve_ami_from_ssm is enabled."
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

variable "subnet_ids" {
  description = "Optional explicit subnet IDs for Auto Scaling Group. Leave empty to auto-discover private subnets."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID used to discover private subnets and create security group."
  type        = string
  default     = null
}

variable "private_subnet_tag_key" {
  description = "Tag key used to discover private subnets when subnet_ids is empty."
  type        = string
  default     = "Tier"
}

variable "private_subnet_tag_values" {
  description = "Tag values used to discover private subnets when subnet_ids is empty."
  type        = list(string)
  default     = ["private"]

  validation {
    condition     = length(var.private_subnet_tag_values) > 0
    error_message = "private_subnet_tag_values must contain at least one value."
  }
}

variable "key_name" {
  description = "Optional existing key pair name used by launch template."
  type        = string
  default     = null
}

variable "ebs_optimized" {
  description = "Enable EBS optimization. Defaults to AWS behavior when null."
  type        = bool
  default     = null
}

variable "detailed_monitoring" {
  description = "Enable EC2 detailed monitoring in launch template."
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

variable "metadata_http_endpoint" {
  description = "Enable or disable instance metadata endpoint."
  type        = string
  default     = "enabled"

  validation {
    condition     = contains(["enabled", "disabled"], var.metadata_http_endpoint)
    error_message = "metadata_http_endpoint must be enabled or disabled."
  }
}

variable "metadata_http_tokens" {
  description = "Metadata service token requirement (optional or required)."
  type        = string
  default     = "required"

  validation {
    condition     = contains(["optional", "required"], var.metadata_http_tokens)
    error_message = "metadata_http_tokens must be optional or required."
  }
}

variable "metadata_http_put_response_hop_limit" {
  description = "Metadata response hop limit."
  type        = number
  default     = 1

  validation {
    condition     = var.metadata_http_put_response_hop_limit >= 1 && var.metadata_http_put_response_hop_limit <= 64
    error_message = "metadata_http_put_response_hop_limit must be between 1 and 64."
  }
}

variable "metadata_instance_metadata_tags" {
  description = "Expose tags in metadata endpoint (enabled or disabled)."
  type        = string
  default     = "disabled"

  validation {
    condition     = contains(["enabled", "disabled"], var.metadata_instance_metadata_tags)
    error_message = "metadata_instance_metadata_tags must be enabled or disabled."
  }
}

variable "create_security_group" {
  description = "Create dedicated security group for instances in the Auto Scaling Group."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Optional explicit name for created security group."
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Description for created security group."
  type        = string
  default     = "Managed by Terraform for EC2 Auto Scaling access."
}

variable "vpc_security_group_ids" {
  description = "Existing security groups attached to launch template instances."
  type        = list(string)
  default     = []
}

variable "security_group_ingress_rules" {
  description = "Ingress rules for created security group. Exactly one source per rule."
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
  description = "Egress rules for created security group. Leave empty to allow all outbound IPv4 traffic."
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
  description = "Create IAM role + instance profile for launch template instances."
  type        = bool
  default     = false
}

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile name to attach when create_instance_profile is false."
  type        = string
  default     = null
}

variable "instance_profile_name" {
  description = "Optional explicit instance profile name when create_instance_profile is true."
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Optional explicit IAM role name when create_instance_profile is true."
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description for created IAM role."
  type        = string
  default     = "Managed by Terraform for EC2 Auto Scaling instance profile."
}

variable "iam_role_path" {
  description = "Path for created IAM role."
  type        = string
  default     = "/"
}

variable "iam_role_permissions_boundary" {
  description = "Optional IAM permissions boundary ARN for created role."
  type        = string
  default     = null
}

variable "iam_role_policy_arns" {
  description = "Managed policy ARNs attached to created IAM role."
  type        = list(string)
  default     = []
}

variable "root_device_name" {
  description = "Device name for optional root block device mapping."
  type        = string
  default     = "/dev/xvda"
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

  validation {
    condition = var.root_block_device == null || (
      try(var.root_block_device.volume_type, null) == null || try(contains([
        "gp2", "gp3", "io1", "io2", "st1", "sc1", "standard"
      ], var.root_block_device.volume_type), false)
    )
    error_message = "root_block_device.volume_type must be one of: gp2, gp3, io1, io2, st1, sc1, standard."
  }

  validation {
    condition = var.root_block_device == null || (
      try(var.root_block_device.iops, null) == null || try(contains(["gp3", "io1", "io2"], coalesce(try(var.root_block_device.volume_type, null), "gp3")), false)
    )
    error_message = "root_block_device.iops can only be configured with volume_type gp3, io1, or io2."
  }

  validation {
    condition = var.root_block_device == null || (
      try(var.root_block_device.throughput, null) == null || try(coalesce(try(var.root_block_device.volume_type, null), "gp3") == "gp3", false)
    )
    error_message = "root_block_device.throughput can only be configured with volume_type gp3."
  }

  validation {
    condition = var.root_block_device == null || (
      try(var.root_block_device.volume_size, null) == null || try(var.root_block_device.volume_size > 0, false)
    )
    error_message = "root_block_device.volume_size must be greater than 0 when provided."
  }
}

variable "ebs_block_devices" {
  description = "Additional block device mappings for launch template."
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

  validation {
    condition = alltrue([
      for device in var.ebs_block_devices : (
        try(device.volume_type, null) == null || try(contains([
          "gp2", "gp3", "io1", "io2", "st1", "sc1", "standard"
        ], device.volume_type), false)
      )
    ])
    error_message = "ebs_block_devices.volume_type must be one of: gp2, gp3, io1, io2, st1, sc1, standard."
  }

  validation {
    condition = alltrue([
      for device in var.ebs_block_devices : (
        try(device.iops, null) == null || try(contains(["gp3", "io1", "io2"], coalesce(try(device.volume_type, null), "gp3")), false)
      )
    ])
    error_message = "ebs_block_devices.iops can only be configured with volume_type gp3, io1, or io2."
  }

  validation {
    condition = alltrue([
      for device in var.ebs_block_devices : (
        try(device.throughput, null) == null || try(coalesce(try(device.volume_type, null), "gp3") == "gp3", false)
      )
    ])
    error_message = "ebs_block_devices.throughput can only be configured with volume_type gp3."
  }

  validation {
    condition = alltrue([
      for device in var.ebs_block_devices : (
        try(device.volume_size, null) == null || try(device.volume_size > 0, false)
      )
    ])
    error_message = "ebs_block_devices.volume_size must be greater than 0 when provided."
  }
}

variable "min_size" {
  description = "Minimum number of instances in Auto Scaling Group."
  type        = number
  default     = 1

  validation {
    condition     = var.min_size >= 0
    error_message = "min_size must be greater than or equal to 0."
  }
}

variable "max_size" {
  description = "Maximum number of instances in Auto Scaling Group."
  type        = number
  default     = 3

  validation {
    condition     = var.max_size >= 0
    error_message = "max_size must be greater than or equal to 0."
  }
}

variable "desired_capacity" {
  description = "Desired number of instances in Auto Scaling Group."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_capacity >= 0
    error_message = "desired_capacity must be greater than or equal to 0."
  }
}

variable "default_cooldown" {
  description = "Cooldown time in seconds after a scaling activity."
  type        = number
  default     = 300

  validation {
    condition     = var.default_cooldown >= 0
    error_message = "default_cooldown must be greater than or equal to 0."
  }
}

variable "health_check_type" {
  description = "Health check type (EC2 or ELB)."
  type        = string
  default     = "EC2"

  validation {
    condition     = contains(["EC2", "ELB"], var.health_check_type)
    error_message = "health_check_type must be EC2 or ELB."
  }
}

variable "health_check_grace_period" {
  description = "Time in seconds before checking health after instance launch."
  type        = number
  default     = 300

  validation {
    condition     = var.health_check_grace_period >= 0
    error_message = "health_check_grace_period must be greater than or equal to 0."
  }
}

variable "target_group_arns" {
  description = "Target group ARNs attached to Auto Scaling Group."
  type        = list(string)
  default     = []
}

variable "termination_policies" {
  description = "Optional list of termination policies used by Auto Scaling Group."
  type        = list(string)
  default     = []
}

variable "protect_from_scale_in" {
  description = "Enable scale-in protection for instances."
  type        = bool
  default     = false
}

variable "wait_for_capacity_timeout" {
  description = "Maximum duration Terraform waits for ASG capacity before timing out."
  type        = string
  default     = "10m"
}

variable "force_delete" {
  description = "Allow force deletion of Auto Scaling Group without waiting for instances."
  type        = bool
  default     = false
}

variable "capacity_rebalance" {
  description = "Enable capacity rebalance for Spot instances."
  type        = bool
  default     = false
}

variable "max_instance_lifetime" {
  description = "Maximum lifetime in seconds for instances in Auto Scaling Group."
  type        = number
  default     = null

  validation {
    condition     = var.max_instance_lifetime == null || try(var.max_instance_lifetime >= 86400, false)
    error_message = "max_instance_lifetime must be at least 86400 seconds when provided."
  }
}

variable "enabled_metrics" {
  description = "Group metrics enabled for Auto Scaling Group."
  type        = list(string)
  default     = []
}

variable "metrics_granularity" {
  description = "Granularity for enabled Auto Scaling Group metrics."
  type        = string
  default     = "1Minute"

  validation {
    condition     = contains(["1Minute"], var.metrics_granularity)
    error_message = "metrics_granularity must be 1Minute."
  }
}

variable "cpu_target_tracking_enabled" {
  description = "Enable built-in CPU target tracking scaling policy."
  type        = bool
  default     = false
}

variable "cpu_target_tracking_target_value" {
  description = "Target CPU utilization percentage used by built-in CPU target tracking policy."
  type        = number
  default     = 60

  validation {
    condition     = var.cpu_target_tracking_target_value > 0
    error_message = "cpu_target_tracking_target_value must be greater than 0."
  }
}

variable "cpu_target_tracking_disable_scale_in" {
  description = "Disable scale-in behavior in built-in CPU target tracking policy."
  type        = bool
  default     = false
}

variable "cpu_target_tracking_estimated_instance_warmup" {
  description = "Estimated warmup time in seconds for built-in CPU target tracking policy."
  type        = number
  default     = null

  validation {
    condition     = var.cpu_target_tracking_estimated_instance_warmup == null || try(var.cpu_target_tracking_estimated_instance_warmup >= 0, false)
    error_message = "cpu_target_tracking_estimated_instance_warmup must be greater than or equal to 0 when provided."
  }
}

variable "target_tracking_policies" {
  description = "Optional additional target tracking policies."
  type = list(object({
    name                      = string
    target_value              = number
    disable_scale_in          = optional(bool, false)
    estimated_instance_warmup = optional(number)
    predefined_metric_type    = optional(string, "ASGAverageCPUUtilization")
    resource_label            = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.target_tracking_policies : (
        policy.target_value > 0
      )
    ])
    error_message = "target_tracking_policies.target_value must be greater than 0."
  }

  validation {
    condition = alltrue([
      for policy in var.target_tracking_policies : (
        try(policy.estimated_instance_warmup, null) == null || try(policy.estimated_instance_warmup >= 0, false)
      )
    ])
    error_message = "target_tracking_policies.estimated_instance_warmup must be greater than or equal to 0 when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.target_tracking_policies : (
        contains([
          "ASGAverageCPUUtilization",
          "ASGAverageNetworkIn",
          "ASGAverageNetworkOut",
          "ALBRequestCountPerTarget"
        ], coalesce(try(policy.predefined_metric_type, null), "ASGAverageCPUUtilization"))
      )
    ])
    error_message = "target_tracking_policies.predefined_metric_type must be one of ASGAverageCPUUtilization, ASGAverageNetworkIn, ASGAverageNetworkOut, ALBRequestCountPerTarget."
  }
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "autoscaling_group_tags" {
  description = "Additional tags propagated by Auto Scaling Group to launched instances."
  type        = map(string)
  default     = {}
}

variable "launch_template_tags" {
  description = "Additional tags for launch template resource."
  type        = map(string)
  default     = {}
}

variable "instance_tags" {
  description = "Additional tags for launched instances."
  type        = map(string)
  default     = {}
}

variable "volume_tags" {
  description = "Additional tags for EBS volumes launched from launch template."
  type        = map(string)
  default     = {}
}

variable "security_group_tags" {
  description = "Additional tags for created security group."
  type        = map(string)
  default     = {}
}

variable "iam_role_tags" {
  description = "Additional tags for created IAM role."
  type        = map(string)
  default     = {}
}

variable "instance_profile_tags" {
  description = "Additional tags for created IAM instance profile."
  type        = map(string)
  default     = {}
}

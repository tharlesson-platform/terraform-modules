variable "name" {
  description = "Base name used for EC2 resources."
  type        = string
}

variable "instance_name" {
  description = "Optional explicit Name tag for the instance. Defaults to name."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type (for example t3.micro)."
  type        = string
}

variable "subnet_id" {
  description = "Optional explicit subnet ID where the instance will be launched."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID used to discover private subnets when subnet_id is null."
  type        = string
  default     = null
}

variable "private_subnet_tag_key" {
  description = "Tag key used to discover private subnets when subnet_id is null."
  type        = string
  default     = "Tier"
}

variable "private_subnet_tag_values" {
  description = "Tag values used to discover private subnets when subnet_id is null."
  type        = list(string)
  default     = ["private"]

  validation {
    condition     = length(var.private_subnet_tag_values) > 0
    error_message = "private_subnet_tag_values must contain at least one value."
  }
}

variable "ami_id" {
  description = "Optional explicit AMI ID. If null and resolve_ami_from_ssm=true, AMI will be resolved from SSM parameter."
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

variable "availability_zone" {
  description = "Optional explicit availability zone. Usually inferred from resolved subnet."
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Associate a public IPv4 address on launch."
  type        = bool
  default     = null
}

variable "private_ip" {
  description = "Optional fixed private IPv4 address."
  type        = string
  default     = null
}

variable "secondary_private_ips" {
  description = "Optional secondary private IPv4 addresses."
  type        = list(string)
  default     = []
}

variable "ipv6_address_count" {
  description = "Number of IPv6 addresses assigned to the primary network interface."
  type        = number
  default     = null

  validation {
    condition     = var.ipv6_address_count == null || try(var.ipv6_address_count >= 0, false)
    error_message = "ipv6_address_count must be greater than or equal to 0 when provided."
  }
}

variable "ipv6_addresses" {
  description = "Specific IPv6 addresses assigned to the primary network interface."
  type        = list(string)
  default     = []
}

variable "source_dest_check" {
  description = "Enable source/destination checks."
  type        = bool
  default     = true
}

variable "key_name" {
  description = "Existing key pair name to use."
  type        = string
  default     = null
}

variable "create_key_pair" {
  description = "Create a new EC2 key pair in this module."
  type        = bool
  default     = false
}

variable "key_pair_name" {
  description = "Name used when create_key_pair is true."
  type        = string
  default     = null
}

variable "public_key" {
  description = "Public key material used when create_key_pair is true."
  type        = string
  default     = null
}

variable "create_security_group" {
  description = "Create dedicated security group for this instance."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Optional explicit name for the created security group."
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Description for created security group."
  type        = string
  default     = "Managed by Terraform for EC2 access."
}

variable "vpc_security_group_ids" {
  description = "Existing security group IDs attached to the instance."
  type        = list(string)
  default     = []
}

variable "security_group_ingress_rules" {
  description = "Ingress rules for created security group. Exactly one source per rule (cidr_ipv4, cidr_ipv6, prefix_list_id, or referenced_security_group_id)."
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
  description = "Egress rules for created security group. Leave empty to create default allow-all egress rule."
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
  description = "Create IAM role + instance profile for EC2 instance."
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
  default     = "Managed by Terraform for EC2 instance profile."
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

variable "user_data_replace_on_change" {
  description = "Replace instance when user_data or user_data_base64 changes."
  type        = bool
  default     = true
}

variable "monitoring" {
  description = "Enable detailed monitoring."
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "Enable EBS optimization. Defaults to AWS behavior when null."
  type        = bool
  default     = null
}

variable "disable_api_termination" {
  description = "Enable termination protection."
  type        = bool
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Action when instance executes OS shutdown command (stop or terminate)."
  type        = string
  default     = "stop"

  validation {
    condition     = contains(["stop", "terminate"], var.instance_initiated_shutdown_behavior)
    error_message = "instance_initiated_shutdown_behavior must be stop or terminate."
  }
}

variable "tenancy" {
  description = "Instance tenancy (default, dedicated, or host)."
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated", "host"], var.tenancy)
    error_message = "tenancy must be default, dedicated, or host."
  }
}

variable "hibernation" {
  description = "Enable hibernation support."
  type        = bool
  default     = false
}

variable "cpu_core_count" {
  description = "Optional number of CPU cores for instance CPU options."
  type        = number
  default     = null

  validation {
    condition     = var.cpu_core_count == null || try(var.cpu_core_count > 0, false)
    error_message = "cpu_core_count must be greater than 0 when provided."
  }
}

variable "cpu_threads_per_core" {
  description = "Optional threads per CPU core for instance CPU options."
  type        = number
  default     = null

  validation {
    condition     = var.cpu_threads_per_core == null || try(var.cpu_threads_per_core > 0, false)
    error_message = "cpu_threads_per_core must be greater than 0 when provided."
  }
}

variable "cpu_credits" {
  description = "CPU credits option for burstable instances (standard or unlimited)."
  type        = string
  default     = null

  validation {
    condition     = var.cpu_credits == null || try(contains(["standard", "unlimited"], var.cpu_credits), false)
    error_message = "cpu_credits must be standard or unlimited when provided."
  }
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

variable "manage_root_block_device" {
  description = "If true, configure root block device settings in this module."
  type        = bool
  default     = false
}

variable "root_volume_type" {
  description = "Root volume type when manage_root_block_device is true."
  type        = string
  default     = null

  validation {
    condition = var.root_volume_type == null || try(contains([
      "gp2", "gp3", "io1", "io2", "st1", "sc1", "standard"
    ], var.root_volume_type), false)
    error_message = "root_volume_type must be one of: gp2, gp3, io1, io2, st1, sc1, standard."
  }
}

variable "root_volume_size" {
  description = "Root volume size in GiB when manage_root_block_device is true."
  type        = number
  default     = null

  validation {
    condition     = var.root_volume_size == null || try(var.root_volume_size > 0, false)
    error_message = "root_volume_size must be greater than 0 when provided."
  }
}

variable "root_iops" {
  description = "Root volume IOPS when supported by root_volume_type."
  type        = number
  default     = null

  validation {
    condition     = var.root_iops == null || try(var.root_iops > 0, false)
    error_message = "root_iops must be greater than 0 when provided."
  }
}

variable "root_throughput" {
  description = "Root volume throughput in MiB/s (gp3 only)."
  type        = number
  default     = null

  validation {
    condition     = var.root_throughput == null || try(var.root_throughput > 0, false)
    error_message = "root_throughput must be greater than 0 when provided."
  }
}

variable "root_encrypted" {
  description = "Encrypt root volume when manage_root_block_device is true."
  type        = bool
  default     = true
}

variable "root_kms_key_id" {
  description = "Optional KMS key ARN/ID for root volume encryption."
  type        = string
  default     = null
}

variable "root_delete_on_termination" {
  description = "Delete root volume when instance is terminated."
  type        = bool
  default     = true
}

variable "ebs_block_devices" {
  description = "Additional EBS block devices attached by aws_instance."
  type = list(object({
    device_name           = string
    volume_size           = optional(number)
    volume_type           = optional(string)
    iops                  = optional(number)
    throughput            = optional(number)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string)
    snapshot_id           = optional(string)
    delete_on_termination = optional(bool, true)
    tags                  = optional(map(string), {})
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

variable "associate_eip" {
  description = "Associate Elastic IP to the instance."
  type        = bool
  default     = false
}

variable "eip_allocation_id" {
  description = "Existing EIP allocation ID to associate when associate_eip is true."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "instance_tags" {
  description = "Additional tags only for EC2 instance."
  type        = map(string)
  default     = {}
}

variable "security_group_tags" {
  description = "Additional tags for created security group."
  type        = map(string)
  default     = {}
}

variable "key_pair_tags" {
  description = "Additional tags for created key pair."
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

variable "eip_tags" {
  description = "Additional tags for created Elastic IP."
  type        = map(string)
  default     = {}
}

variable "root_volume_tags" {
  description = "Additional tags for managed root volume."
  type        = map(string)
  default     = {}
}

variable "volume_tags" {
  description = "Additional tags for all EBS volumes managed by aws_instance."
  type        = map(string)
  default     = {}
}

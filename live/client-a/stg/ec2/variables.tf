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
  default     = "terraform-ec2"
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
  description = "Workload suffix used in instance naming."
  type        = string
  default     = "app-01"
}

variable "instance_name" {
  description = "Optional explicit Name tag for the EC2 instance."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Optional explicit subnet ID for EC2. Leave null to auto-discover private subnet in vpc_id."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID used to discover private subnet when subnet_id is null."
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

variable "create_security_group" {
  description = "Create dedicated security group for instance."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Optional explicit security group name."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "Existing security groups attached to instance."
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

variable "key_name" {
  description = "Existing key pair name."
  type        = string
  default     = null
}

variable "create_key_pair" {
  description = "Create EC2 key pair in this stack."
  type        = bool
  default     = false
}

variable "key_pair_name" {
  description = "Key pair name when create_key_pair is true."
  type        = string
  default     = null
}

variable "public_key" {
  description = "Public key material when create_key_pair is true."
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Associate public IPv4 on launch."
  type        = bool
  default     = false
}

variable "private_ip" {
  description = "Optional fixed private IPv4."
  type        = string
  default     = null
}

variable "monitoring" {
  description = "Enable EC2 detailed monitoring (1-minute metrics)."
  type        = bool
  default     = true
}

variable "user_data" {
  description = "Plain-text user data script."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Base64-encoded user data."
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Replace instance when user_data changes."
  type        = bool
  default     = true
}

variable "manage_root_block_device" {
  description = "Manage root block device attributes in this stack."
  type        = bool
  default     = false
}

variable "root_volume_type" {
  description = "Root volume type when manage_root_block_device is true."
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Root volume size in GiB when manage_root_block_device is true."
  type        = number
  default     = null
}

variable "ebs_block_devices" {
  description = "Additional EBS block devices attached to EC2 instance."
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
}

variable "associate_eip" {
  description = "Associate Elastic IP to the instance."
  type        = bool
  default     = false
}

variable "eip_allocation_id" {
  description = "Existing EIP allocation ID to associate."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}

region      = "us-east-1"
aws_profile = "client-a-dev"

# Para multi-conta, use role cross-account (opcional)
aws_assume_role_arn          = "arn:aws:iam::123456789012:role/terraform-deploy"
aws_assume_role_session_name = "terraform-ec2-autoscaling-client-a-dev"

client        = "client-a"
environment   = "dev"
workload_name = "app"

# Output do stack vpc
vpc_id     = "vpc-0123456789abcdef0"
subnet_ids = []

private_subnet_tag_key    = "Tier"
private_subnet_tag_values = ["private"]

instance_type = "t3.micro"
instance_name = null

ami_id                 = null
resolve_ami_from_ssm   = true
ami_ssm_parameter_name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"

key_name            = null
ebs_optimized       = null
detailed_monitoring = true

create_security_group  = true
security_group_name    = null
vpc_security_group_ids = []

security_group_ingress_rules = [
  {
    description = "HTTP from corporate network"
    ip_protocol = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_ipv4   = "10.50.0.0/16"
  }
]

security_group_egress_rules = []

create_instance_profile   = true
iam_instance_profile_name = null
instance_profile_name     = null
iam_role_name             = null
iam_role_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
]

user_data        = null
user_data_base64 = null

root_block_device = null
ebs_block_devices = []

min_size         = 1
desired_capacity = 1
max_size         = 2

health_check_type         = "EC2"
health_check_grace_period = 300
default_cooldown          = 300

target_group_arns         = []
termination_policies      = []
protect_from_scale_in     = false
wait_for_capacity_timeout = "10m"
force_delete              = false
capacity_rebalance        = false
max_instance_lifetime     = null

enabled_metrics = [
  "GroupDesiredCapacity",
  "GroupInServiceInstances",
  "GroupTotalInstances"
]
metrics_granularity = "1Minute"

cpu_target_tracking_enabled                   = true
cpu_target_tracking_target_value              = 60
cpu_target_tracking_disable_scale_in          = false
cpu_target_tracking_estimated_instance_warmup = 180
target_tracking_policies                      = []

tags = {
  Owner      = "platform-team"
  CostCenter = "shared-services"
  Terraform  = "true"
}

region      = "us-east-1"
aws_profile = "client-a-stg"

# Para multi-conta, use role cross-account (opcional)
aws_assume_role_arn          = "arn:aws:iam::123456789012:role/terraform-deploy"
aws_assume_role_session_name = "terraform-ec2-client-a-stg"

client        = "client-a"
environment   = "stg"
workload_name = "app-01"

# Output do stack vpc
vpc_id    = "vpc-0123456789abcdef0"
subnet_id = null

private_subnet_tag_key    = "Tier"
private_subnet_tag_values = ["private"]

instance_type = "t3.micro"
instance_name = null

ami_id                 = null
resolve_ami_from_ssm   = true
ami_ssm_parameter_name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"

create_security_group  = true
security_group_name    = null
vpc_security_group_ids = []

security_group_ingress_rules = [
  {
    description = "SSH from corporate network"
    ip_protocol = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_ipv4   = "10.51.0.0/16"
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

key_name        = null
create_key_pair = false
key_pair_name   = null
public_key      = null

associate_public_ip_address = false
private_ip                  = null
monitoring                  = true

user_data = null

user_data_base64            = null
user_data_replace_on_change = true

manage_root_block_device = false
root_volume_type         = null
root_volume_size         = null

ebs_block_devices = []

associate_eip     = false
eip_allocation_id = null

tags = {
  Owner      = "platform-team"
  CostCenter = "shared-services"
  Terraform  = "true"
}


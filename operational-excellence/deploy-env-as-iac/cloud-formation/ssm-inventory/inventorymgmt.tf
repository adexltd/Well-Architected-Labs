terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile = "admin1"
}

# CREATE ROLE AND ATTACH TRUSTED ENTITY EC2 WIHT PRINCIPLE SSM
resource "aws_iam_role" "ManagedInstancesRole" {
  name = "ManagedInstancesRole"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ssm.amazonaws.com"
                ]
            }
        }
    ]
}
EOF
}
# ATTACH EC2 POLICY ROLE TO ManagedInstancesRole
resource "aws_iam_role_policy_attachment" "ec2_policy" {
  role       = aws_iam_role.ManagedInstancesRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# SSM ACTIVATION 
resource "aws_ssm_activation" "ec2_ssm" {
  name               = "ec2_ssm"
  description        = "Test"
  iam_role           = aws_iam_role.ManagedInstancesRole.id
  registration_limit = "3"
  depends_on         = [aws_iam_role_policy_attachment.ec2_policy]
}

# CREATE INSTANCE PROFILE
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ManagedInstancesRole.name
}

# CREATE EC2 INSTACE
resource "aws_instance" "ec2" {
  ami = "ami-00d8a762cb0c50254"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name = "rsa-key"

  tags = {
    "Name" = "test-ec2"
    owner = ""
    stack = "test"
  }
}
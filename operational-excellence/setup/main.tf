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
  profile = "amrit"
}


resource "aws_iam_group" "administrators" {
  name = "administrators"
  path = "/users/"
}

resource "aws_iam_group_policy" "my_administrators_policy" {
  name = "my_administrators_policy"
  group = aws_iam_group.administrators.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_user" "admin1" {
  name = "admin1"
}

resource "aws_iam_user" "admin2" {
  name = "admin2"
}

resource "aws_iam_group_membership" "administrators-users" {
  name = "administrators-users"

  users = [
    aws_iam_user.admin1.name,
    aws_iam_user.admin2.name,
  ]

  group = aws_iam_group.administrators.name
}

resource "aws_iam_user_login_profile" "admin1" {
  user    = aws_iam_user.admin1.name
}

# output "password" {
#   value = aws_iam_user_login_profile.admin1.encrypted_password
# }

resource "aws_iam_access_key" "admin1" {
  user = aws_iam_user.admin1.name
}

output "aws_iam_smtp_password_v4" {
  value = aws_iam_access_key.admin1.ses_smtp_password_v4
  sensitive = true
}

# EC2 KEY PAIR
resource "aws_key_pair" "rsa" {
  key_name   = "rsa-key"
  public_key = file("~/.ssh/rsa_key.pub")
  }
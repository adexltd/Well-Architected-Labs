provider "aws" {
  region = "us-west-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile = "admin1"
}

resource "aws_iam_role" "SSMMaintenanceWindowRole" {
  name = "SSMMaintenanceWindowRole"
  description = "Role for Amazon SSMMaintenanceWindow"

  assume_role_policy = jsonencode({
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"",
         "Effect":"Allow",
         "Principal":{
            "Service":[
               "ec2.amazonaws.com",
               "ssm.amazonaws.com",
               "sns.amazonaws.com"
            ]
         },
         "Action":"sts:AssumeRole"
      }
   ]
  })


}

# ATTACH POLICY
resource "aws_iam_role_policy_attachment" "ssm_maintenance_policy" {
  role       = aws_iam_role.SSMMaintenanceWindowRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

# CREATE SSMMaintenanceWindowPassRole POLICY
resource "aws_iam_policy" "SSMMaintenanceWindowPassRole" {
  name        = "SSMMaintenanceWindowPassRole"
  description = "My SSMMaintenanceWindowPassRole policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:PassRole*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# To assign the IAM PassRole policy to your Administrators IAM user group
resource "aws_iam_group" "administrators1" {
  name = "administrators1"
  path = "/users/"
}

# ATTACH POLICY TO GROUP Administrators
resource "aws_iam_group_policy_attachment" "ssm_maintenance_group_policy" {
  group      = aws_iam_group.administrators1.name
  policy_arn = aws_iam_policy.SSMMaintenanceWindowPassRole.arn
}

# Create a Patch Maintenance Window
resource "aws_ssm_maintenance_window" "PatchTestWorkloadWebServers" {
  name     = "PatchTestWorkloadWebServers"
  schedule = "cron(0 16 ? * TUE *)"
  duration = 3
  cutoff   = 1
}

# Assigning Targets to Your Patch Maintenance Window
resource "aws_ssm_maintenance_window_target" "TestWebServers" {
  window_id = aws_ssm_maintenance_window.PatchTestWorkloadWebServers.id
  name = "TestWebServers"
  description   = "This is a maintenance window target"
  resource_type = "INSTANCE"

  targets {
    key = "tag:Workload"
    values = ["Test"]

  }

}

# Assigning Tasks to Your Patch Maintenance Window
resource "aws_ssm_maintenance_window_task" "PatchTestWorkloadWebServers" {
  max_concurrency = 2
  max_errors      = 1
  priority        = 1
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.PatchTestWorkloadWebServers.id

  targets {
    key    = "InstanceIds"
    values = [aws_instance.PatchTestWorkloadWebServers.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      output_s3_bucket     = aws_s3_bucket.PatchTestWorkloadWebServers.bucket
      output_s3_key_prefix = "output"
      service_role_arn     = aws_iam_role.PatchTestWorkloadWebServers.arn
      timeout_seconds      = 600

      notification_config {
        notification_arn    = aws_sns_topic.PatchTestWorkloadWebServers.arn
        notification_events = ["All"]
        notification_type   = "Command"
      }

      parameter {
        name   = "commands"
        values = ["date"]
      }
    }
  }
}
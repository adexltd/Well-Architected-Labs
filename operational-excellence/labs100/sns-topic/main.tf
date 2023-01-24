provider "aws" {
  region = "us-west-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile = "amrit"
}

# Create and Subscribe to an SNS Topic
resource "aws_sns_topic" "AdminAlert" {
  display_name = "AdminAlert"
}

resource "aws_sqs_queue" "user_updates_queue" {
  name = "user-updates-queue"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.AdminAlert.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.user_updates_queue.arn
}

variable "sns" {
  default = {
    account-id   = "example@adex.ltd"
    role-name    = "service/service-hashicorp-terraform"
    name         = "AdminAlert"
    display_name = "AdminAlert"
    region       = "us-west-1"
  }
}
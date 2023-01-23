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

resource "aws_ssm_patch_baseline" "production" {
  name             = "patch-baseline"
  description      = "Patch Baseline Description"
  approved_patches = ["KB123456", "KB456789"]
  rejected_patches = ["KB987654"]

  global_filter {
    key    = "PRODUCT"
    values = ["WindowsServer2008"]
  }

  global_filter {
    key    = "CLASSIFICATION"
    values = ["ServicePacks"]
  }

  global_filter {
    key    = "MSRC_SEVERITY"
    values = ["Low"]
  }

  approval_rule {
    approve_after_days = 7
    compliance_level   = "HIGH"

    patch_filter {
      key    = "PRODUCT"
      values = ["WindowsServer2016"]
    }

    patch_filter {
      key    = "CLASSIFICATION"
      values = ["CriticalUpdates", "SecurityUpdates", "Updates"]
    }

    patch_filter {
      key    = "MSRC_SEVERITY"
      values = ["Critical", "Important", "Moderate"]
    }
  }

  approval_rule {
    approve_after_days = 7

    patch_filter {
      key    = "PRODUCT"
      values = ["WindowsServer2012"]
    }
  }
}

# Scan Your Instances with AWS-RunPatchBaseline via Run Command

resource "aws_ssm_document" "test-document" {
  name = "test-document"
  document_type = "Command"

  content = <<DOC
{
"schemaVersion": "1.2",
    "description": "Check ip configuration of a Linux instance.",
    "parameters": {

    },
    "runtimeConfig": {
      "aws:runShellScript": {
        "properties": [
          {
            "id": "0.aws:runShellScript",
            "runCommand": ["ifconfig"]
          }
        ]
      }
    }
  }
  }
  DOC
}


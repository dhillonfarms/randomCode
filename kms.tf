resource "aws_kms_key" "a" {
    description = "Test Key for S3"
    policy = data.aws_iam_policy_document.base_policy.json
    is_enabled = true
    enable_key_rotation = true
}

resource "aws_kms_alias" "a" {
  name          = "alias/hd-s3-key"
  target_key_id = aws_kms_key.a.key_id
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "base_policy" {
  statement {
    sid = "EnableIAMUserPermissions"
    effect = "Allow"
    actions = ["kms:*"]
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
    resources = ["*"]
  }

  statement {
    sid = "EnableIAMAdminPermissions"
    effect = "Allow"
    actions = [
        "kms:Create",
        "kms:Describe",
        "kms:List",
        "kms:Put",
        "kms:Update",
        "kms:Revoke",
        "kms:Disable",
        "kms:Get",
        "kms:Delete",
        "kms:TagResource",
        "kms:UnTagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion",
        ]
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:role/Admin"]
    }
    resources = ["*"]
  }
}

# resource "aws_iam_policy" "example" {
#   name   = "kms_s3_policy"
#   policy = data.aws_iam_policy_document.base_policy.json
# }

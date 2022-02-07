# locals {
#   prebuilt_lifecycle_rules = {
#       cleanup_incomplete_
#   }
# }
variable bucket_name {
    default = "hd-bucket-s3kms-8899test-atl"
}

variable policy {
    description = "Valid policy"
    default = ""
    type = string
}

variable kms_key_arn {
    type = string
    default = "value"
}

data aws_iam_policy_document bucket_policy {
    source_json = var.policy

    statement {
      sid = "DenyKeyArnOtherThanAWS:KMS"
      effect = "Deny"
      actions = ["s3:PutObject"]
      principals {
          type = "*"
          identifiers = ["*"]
      }
      resources = ["arn:aws:s3:::${var.bucket_name}/*"]
      condition {
        test = "Null"
        variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
        values = ["false"]
      }
      condition {
        test = "StringNotEquals"
        variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
        values = [aws_kms_key.a.arn]
      }
    }

    statement {
      sid = "DenyEncryptionArnOtherThanAWS:KMS"
      effect = "Deny"
      actions = ["s3:PutObject"]
      principals {
          type = "*"
          identifiers = ["*"]
      }
      resources = ["arn:aws:s3:::${var.bucket_name}/*"]
      condition {
        test = "Null"
        variable = "s3:x-amz-server-side-encryption"
        values = ["false"]
      }
      condition {
        test = "StringNotEquals"
        variable = "s3:x-amz-server-side-encryption"
        values = ["aws:kms"]
      }
    }

    statement {
      sid = "DenyNonSSLTraffic"
      effect = "Deny"
      actions = ["s3:*"]
      principals {
          type = "*"
          identifiers = ["*"]
      }
      resources = [format("arn:aws:s3:::${var.bucket_name}/*")]
      condition {
        test = "Bool"
        variable = "aws:SecureTransport"
        values = ["false"]
      }
    }

    depends_on = [aws_kms_key.a]
}


resource aws_s3_bucket base_bucket {
    #count = 1
    bucket = var.bucket_name
    acl = "private"
    policy = data.aws_iam_policy_document.bucket_policy.json
    force_destroy = true

    versioning {
        enabled = false
    }

    server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.a.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  depends_on = [
    aws_kms_key.a
  ]
}
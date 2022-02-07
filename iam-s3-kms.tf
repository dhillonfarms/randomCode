# data "aws_region" "current" {}

# data "aws_caller_identity" "current" {}

# Policy to be attached to role so that the role can be assumed
data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

# Policy to access S3 bucket
data "aws_iam_policy_document" "s3-kms-policy" {
  statement {
    sid = "ListObjectsInBucket"
    effect = "Allow"
    actions = ["s3:ListBucket"]
    resources = [format("arn:aws:s3:::%s", aws_s3_bucket.base_bucket.id)]
  }
  statement {
    sid = "AllowObjectActions"
    effect = "Allow"
    actions = ["s3:*Object*"]
    resources = [format("arn:aws:s3:::%s/*", aws_s3_bucket.base_bucket.id)]
  }
  statement {
    sid = "AllowKMSOperation"
    effect = "Allow"
    actions = ["kms:GenerateDataKey"]
    resources = [format("arn:aws:kms:%s:%s:key/%s", data.aws_region.current.name, data.aws_caller_identity.current.account_id, aws_kms_key.a.key_id)]
  }
  depends_on = [aws_kms_key.a]
}


# Create a role
resource "aws_iam_role" "s3-kms-hd_role" {
    name = "HD-S3-KMS-Role"
    tags = {
        name = "HD-S3-KMS-Role"
    }
    assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
}

# Create an IAM Policy to access S3
resource "aws_iam_policy" "s3-kms-hd-accesspolicy" {
  name   = "s3-kms-hd-accesspolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.s3-kms-policy.json
}

# Attach S3 policy with Role
resource "aws_iam_role_policy_attachment" "s3-kms-hd-role-policy-attach" {
  role       = aws_iam_role.s3-kms-hd_role.name
  policy_arn = aws_iam_policy.s3-kms-hd-accesspolicy.arn
}


# Create a User
resource "aws_iam_user" "s3-kms-hd_user" {
    name = "HD-S3-KMS-User"
    tags = {
        name = "HD-S3-KMS-User"
    }
}

# data "aws_iam_policy_document" "user-role-policy" {
#   statement {
#     sid = "UserRoleAssume"
#     actions = ["sts:AssumeRole"]
#     resources = [format("arn:aws:iam::%s/role/%s", data.aws_caller_identity.current.account_id, aws_iam_role.s3-kms-hd_role.name)]
#   }
# }

# Attach user policy to user to assume the role
resource "aws_iam_user_policy" "s3-kms-user-policy" {
  name = "s3-kms-hd-user-policy"
  user = aws_iam_user.s3-kms-hd_user.name
  #policy = data.aws_iam_policy_document.user-role-policy.json
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect   = "Allow"
        Resource = format("arn:aws:iam::%s:role/%s", data.aws_caller_identity.current.account_id, aws_iam_role.s3-kms-hd_role.name)
      },
    ]
  })
}

# Create User Access Key
resource "aws_iam_access_key" "s3-kms-hd-user-accesskey" {
  user = aws_iam_user.s3-kms-hd_user.name
}

# Output the access and secret keys
output "user-accesskey" {
  value = aws_iam_access_key.s3-kms-hd-user-accesskey.id
}

# Output the access and secret keys
output "user-secretkey" {
  value = aws_iam_access_key.s3-kms-hd-user-accesskey.secret
}

# user-accesskey = "AKIA2UYFD26B3FFRZDPC"
# user-secretkey = "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"
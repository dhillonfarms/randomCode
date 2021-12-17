# in existing_vpc: main.tf

resource "aws_s3_bucket" "bucket1" {
  bucket = "name-of-bucket"
  acl    = "private"

  tags = {
    Name        = "name-of-bucket"
    Environment = "Dev"
  }
}

resource "aws_iam_policy" "S3_EKS_policy" {
  name        = "EKS-S3-Policy-" # Add nodegroup-cluster name here
  path        = "/"
  description = "EKS S3 PolicyRef"
  policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = ["s3:ListBucket"],
          Resource = [aws_s3_bucket.bucket1.arn]
        },
        {
          Effect = "Allow",
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject"
          ],
          Resource = [join("/", [aws_s3_bucket.b.arn, "*"])]
        }
      ]
    })
}

// Add this variable to managed_nodegroup:
//s3_iam_policy_arn = aws_iam_policy.S3EKSpolicyReference.arn

// In iam.tf for managed_nodegroup:
resource "aws_iam_role_policy_attachment" "add_s3_policy_for_ververica" {
  policy_arn = local.managed_node_group["s3_iam_policy_arn"]
  role       = aws_iam_role.managed_ng.name
}
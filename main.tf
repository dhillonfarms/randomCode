#outputs.tf

output "eks_cluster_id" {
  description = "Kubernetes Cluster Name"
  value       = var.create_eks ? module.aws_eks.cluster_id : "EKS Cluster not enabled"
}

output "eks_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = var.create_eks ? split("//", module.aws_eks.cluster_oidc_issuer_url)[1] : "EKS Cluster not enabled"
}

output "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = var.create_eks ? module.aws_eks.oidc_provider_arn : "EKS Cluster not enabled"
}

# ===================== IAM OUTPUTS =====================
output "cluster_iam_role_arn" {
  description = "ARN of the IAM role used by EKS control plane"
  value       = aws_iam_role.cluster.arn
}

output "node_iam_role_arn" {
  description = "ARN of the IAM role used by EKS worker nodes"
  value       = aws_iam_role.node.arn
}

output "alb_management_policy_arn" {
  description = "ARN of the custom IAM policy for ALB management"
  value       = aws_iam_policy.alb_management.arn
}

# ===================== SECURITY GROUP OUTPUTS =====================
output "cluster_security_group_id" {
  description = "ID of the security group for EKS control plane"
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "ID of the security group for EKS worker nodes"
  value       = aws_security_group.node.id
}

output "alb_security_group_id" {
  description = "ID of the security group for ALB"
  value       = aws_security_group.alb.id
}

# ===================== EKS CLUSTER OUTPUTS =====================
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "eks_cluster_endpoint" {
  description = "Endpoint URL for the EKS cluster API server"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data for the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "eks_cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA (IAM Roles for Service Accounts)"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "eks_cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = aws_eks_cluster.main.version
}

output "eks_cluster_security_group_ids" {
  description = "List of security group IDs attached to the cluster"
  value       = aws_eks_cluster.main.vpc_config[0].security_group_ids
}

# ===================== OIDC PROVIDER OUTPUT =====================
output "oidc_provider_arn" {
  description = "ARN of the OIDC identity provider for IRSA"
  value       = aws_eks_identity_provider_config.oidc.id
}

# ===================== ADDONS OUTPUTS =====================
output "addon_statuses" {
  description = "Status of all installed EKS addons"
  value = {
    coredns   = aws_eks_addon.coredns.status
    kube_proxy = aws_eks_addon.kube_proxy.status
    vpc_cni   = aws_eks_addon.vpc_cni.status
  }
}

# ===================== NODE GROUPS OUTPUTS =====================
output "node_group_names" {
  description = "Names of all EKS node groups"
  value       = { for idx, ng in aws_eks_node_group.main : local.availability_zones[idx] => ng.node_group_name }
}

output "node_group_arns" {
  description = "ARNs of all EKS node groups"
  value       = { for idx, ng in aws_eks_node_group.main : local.availability_zones[idx] => ng.arn }
}

output "node_group_resources" {
  description = "Resource information for all node groups"
  value = {
    for idx, ng in aws_eks_node_group.main : local.availability_zones[idx] => {
      arn         = ng.arn
      status      = ng.status
      scaling_config = ng.scaling_config[0]
      labels      = ng.labels
    }
  }
}

# ===================== KUBECONFIG HELPER =====================
output "kubeconfig_update_command" {
  description = "AWS CLI command to update local kubeconfig"
  value = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.aws_region} --alias ${var.name_prefix}-${var.environment}"
}

# ===================== USEFUL QUERIES =====================
output "cluster_connection_details" {
  description = "All details needed to connect to the cluster"
  value = {
    cluster_name = aws_eks_cluster.main.name
    endpoint     = aws_eks_cluster.main.endpoint
    ca_data      = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    oidc_issuer  = aws_eks_cluster.main.identity[0].oidc[0].issuer
  }
  sensitive = true
}

# ===================== NETWORKING SUMMARY =====================
output "network_summary" {
  description = "Summary of network configuration"
  value = {
    service_cidr = aws_eks_cluster.main.kubernetes_network_config[0].service_ipv4_cidr
    private_endpoint = aws_eks_cluster.main.vpc_config[0].endpoint_private_access
    public_endpoint  = aws_eks_cluster.main.vpc_config[0].endpoint_public_access
    subnet_count     = length(aws_eks_cluster.main.vpc_config[0].subnet_ids)
    security_groups  = aws_eks_cluster.main.vpc_config[0].security_group_ids
  }
}
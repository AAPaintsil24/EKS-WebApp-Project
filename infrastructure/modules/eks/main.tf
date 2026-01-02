resource "aws_iam_role" "cluster" {
  name = "my-eks-cluster-role"
  
  # Who can assume this role? EKS service
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"  # ONLY EKS can use this
      }
    }]
  })
}

resource "aws_iam_role" "node" {
  name = "my-eks-node-role"
  
  # Who can assume this role? EC2 instances
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"  # ONLY EC2 can use this
      }
    }]
  })
}

# Attach cluster policies
# Policy 1: EKS Cluster Policy
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Policy 2: VPC Resource Controller
resource "aws_iam_role_policy_attachment" "cluster_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

# Attach node policies
# Policy 3: Worker Node Policy
resource "aws_iam_role_policy_attachment" "node_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

# Policy 4: CNI Policy
resource "aws_iam_role_policy_attachment" "node_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

# Policy 5: ECR Read Only
resource "aws_iam_role_policy_attachment" "node_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}


# Custom IAM policy for ALB management
resource "aws_iam_policy" "alb_management" {
  name        = "my-eks-alb-management"
  description = "Permissions for ALB creation by Ingress Controller"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        # Add more specific actions as needed
      ]
      Resource = "*"
    }]
  })
}

# Attach to node role (so nodes can manage ALBs)
resource "aws_iam_role_policy_attachment" "node_alb" {
  policy_arn = aws_iam_policy.alb_management.arn
  role       = aws_iam_role.node.name
}

# 1. CLUSTER SECURITY GROUP - Protects EKS control plane
resource "aws_security_group" "cluster" {
  name        = "${var.name_prefix}-${var.environment}-eks-cluster-sg"
  description = "Security group for EKS control plane - Private API only"
  vpc_id      = var.vpc_id

  # Allow all outbound (for cluster to call AWS APIs, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic from control plane"
  }

  tags = {
    Name        = "${var.name_prefix}-${var.environment}-eks-cluster-sg"
    Environment = var.environment
    Component   = "eks-control-plane"
  }
}

# 2. NODE SECURITY GROUP - Protects worker nodes
resource "aws_security_group" "node" {
  name        = "${var.name_prefix}-${var.environment}-eks-node-sg"
  description = "Security group for EKS worker nodes - No direct public access"
  vpc_id      = var.vpc_id

  # Allow all outbound (for pulling images, updates, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic from worker nodes"
  }

  tags = {
    Name        = "${var.name_prefix}-${var.environment}-eks-node-sg"
    Environment = var.environment
    Component   = "eks-worker-nodes"
    "kubernetes.io/cluster/${var.name_prefix}-${var.environment}-cluster" = "owned"
  }
}

# 3. ALB SECURITY GROUP - Protects Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-${var.environment}-alb-sg"
  description = "Security group for ALB - Accepts internet, forwards to nodes only"
  vpc_id      = var.vpc_id

  # Allow all outbound (ALB needs to respond to clients)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ALB to respond to clients"
  }

  tags = {
    Name        = "${var.name_prefix}-${var.environment}-alb-sg"
    Environment = var.environment
    Component   = "load-balancer"
  }
}

# ===================== SECURITY GROUP RULES =====================

# RULE 1/6: Nodes can talk to Cluster API (443)
resource "aws_security_group_rule" "cluster_ingress_from_nodes" {
  description              = "Allow worker nodes to communicate with cluster API"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
}

# RULE 2/6: Cluster API can talk to Nodes (443)
resource "aws_security_group_rule" "node_ingress_from_cluster" {
  description              = "Allow cluster API to communicate with worker nodes"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
}

# RULE 3/6: Node-to-Node communication (All ports)
resource "aws_security_group_rule" "node_ingress_self" {
  description              = "Allow node-to-node communication for pod networking"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
}

# RULE 4/6: Internet HTTP to ALB (80)
resource "aws_security_group_rule" "alb_ingress_http" {
  description       = "Allow HTTP traffic from internet to ALB"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# RULE 5/6: Internet HTTPS to ALB (443)
resource "aws_security_group_rule" "alb_ingress_https" {
  description       = "Allow HTTPS traffic from internet to ALB"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# RULE 6/6: ALB can talk to Nodes (NodePort range 30000-32767)
resource "aws_security_group_rule" "node_ingress_from_alb" {
  description              = "Allow ALB to forward traffic to nodes on NodePort range"
  type                     = "ingress"
  from_port               = 30000
  to_port                 = 32767
  protocol                = "tcp"
  security_group_id       = aws_security_group.node.id
  source_security_group_id = aws_security_group.alb.id
}

# EKS CLUSTER - The Kubernetes API Control Plane
resource "aws_eks_cluster" "main" {
  name     = "${var.name_prefix}-${var.environment}-cluster"
  role_arn = aws_iam_role.cluster.arn  # From your IAM section
  version  = var.kubernetes_version

  # VPC CONFIGURATION - Private Endpoint Only
  vpc_config {
    # Control plane ENIs in PRIVATE K8s subnets only
    subnet_ids = var.private_k8s_subnet_ids
    
    # SECURITY: Private endpoint only - No internet access to API
    endpoint_private_access = true
    endpoint_public_access  = false
    
    # Reference your cluster security group from previous section
    security_group_ids = [aws_security_group.cluster.id]
  }

  # KUBERNETES SERVICE NETWORK - Must not overlap with VPC CIDR
  kubernetes_network_config {
    service_ipv4_cidr = "10.100.0.0/16"  # Different from your VPC 10.0.0.0/22
  }

  # ENABLED LOGS - For audit and troubleshooting
  enabled_cluster_log_types = [
    "api",            # API requests
    "audit",          # Security audit logs
    "authenticator",  # Authentication attempts
    "controllerManager", # Controller operations
    "scheduler"       # Pod scheduling decisions
  ]

  # ENCRYPTION (Optional but recommended for production)
  # Uncomment and provide KMS key ARN for production
  # encryption_config {
  #   resources = ["secrets"]
  #   provider {
  #     key_arn = var.kms_key_arn
  #   }
  # }

  # TAGS for identification
  tags = {
    Name        = "${var.name_prefix}-${var.environment}-eks-cluster"
    Environment = var.environment
    Component   = "eks-control-plane"
    ManagedBy   = "terraform"
  }

  # DEPENDS ON: IAM role must exist first
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
  ]
}

# OIDC IDENTITY PROVIDER - For IAM Roles for Service Accounts (IRSA)
resource "aws_eks_identity_provider_config" "oidc" {
  cluster_name = aws_eks_cluster.main.name

  oidc {
    client_id                     = "sts.amazonaws.com"
    identity_provider_config_name = "${var.name_prefix}-${var.environment}-oidc"
    issuer_url                    = aws_eks_cluster.main.identity[0].oidc[0].issuer
  }

  tags = {
    Name        = "${var.name_prefix}-${var.environment}-oidc-provider"
    Environment = var.environment
    Purpose     = "irsa-authentication"
  }
}

# EKS ADDONS - Essential cluster services
# 1. CoreDNS - Internal DNS service
resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "coredns"
  
  # Use version compatible with your Kubernetes version
  addon_version = var.addon_versions.coredns
  
  resolve_conflicts = "OVERWRITE"
  
  tags = {
    Name        = "${var.name_prefix}-${var.environment}-coredns-addon"
    Environment = var.environment
  }
  
  depends_on = [aws_eks_cluster.main]
}

# 2. kube-proxy - Network traffic routing
resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "kube-proxy"
  
  addon_version = var.addon_versions.kube_proxy
  
  resolve_conflicts = "OVERWRITE"
  
  tags = {
    Name        = "${var.name_prefix}-${var.environment}-kube-proxy-addon"
    Environment = var.environment
  }
  
  depends_on = [aws_eks_cluster.main]
}

# 3. vpc-cni - AWS VPC networking for pods
resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "vpc-cni"
  
  addon_version = var.addon_versions.vpc_cni
  
  resolve_conflicts = "OVERWRITE"
  
  tags = {
    Name        = "${var.name_prefix}-${var.environment}-vpc-cni-addon"
    Environment = var.environment
  }
  
  depends_on = [aws_eks_cluster.main]
}

resource "aws_eks_node_group" "main" {
  count = length(local.availability_zones)  # Creates 2 resources

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.name_prefix}-${var.environment}-${local.availability_zones[count.index]}"
  node_role_arn   = aws_iam_role.node.arn
  
  # Each iteration gets a different subnet
  subnet_ids      = [var.private_k8s_subnet_ids[count.index]]
  
  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"
  ami_type       = "AL2_x86_64"
  disk_size      = 20

  labels = {
    "az"          = local.availability_zones[count.index]
    "nodegroup"   = "primary"
    "environment" = var.environment
  }

  update_config {
    max_unavailable_percentage = 33
  }

  tags = {
    Name        = "${var.name_prefix}-${var.environment}-${local.availability_zones[count.index]}-nodegroup"
    Environment = var.environment
    AZ          = local.availability_zones[count.index]
    ManagedBy   = "terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}
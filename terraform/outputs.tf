output "cluster_name" {
  description = "L'URL API du Control Plane EKS"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "ID du Security Group (Pare-feu) du cluster"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "Région AWS"
  value       = var.aws_region
}

output "configure_kubectl" {
  description = "Commande pour se connecter au cluster"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${var.cluster_name}"
}

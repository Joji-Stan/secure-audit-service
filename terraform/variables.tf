variable "aws_region" {
  description = "Région AWS cible"
  type        = string
  default     = "eu-west-3" # Paris
}

variable "cluster_name" {
  description = "Nom du cluster Kubernetes"
  type        = string
  default     = "secure-audit-prod"
}

variable "vpc_cidr" {
  description = "Plage IP du réseau virtuel"
  type        = string
  default     = "10.0.0.0/16"
}
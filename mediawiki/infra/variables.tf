variable "location" {
  type    = string
  default = ""
}

variable "subscription_id" {
  type    = string
  default = ""
}

variable "tenant_id" {
  type    = string
  default = ""
}

variable "env" {
  type    = string
  default = "dev"
}

variable "default_tag" {
  default = {
    System = "dev"
  }
}

variable "resource_group" {
  type    = string
  default = ""
}

variable "vnet_name" {
  type    = string
  default = ""
}

variable "subnet_name" {
  type    = string
  default = ""
}

variable "cluster_name" {
  type    = string
  default = ""
}

variable "nodepool_name" {
  type    = string
  default = ""
}

variable "aks_kubernetes_version" {
  type        = string
  description = "Kubernetes Version."
}
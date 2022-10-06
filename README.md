# Kube metrics Terraform module
A Terraform module to configure [`kube-state-metrics`](https://github.com/kubernetes/kube-state-metrics) in the 'standard' deployment model provided, using the [Kubernetes provider](https://registry.terraform.io/providers/hashicorp/kubernetes).

## Overview
Managed Kubernetes cloud providers, such as DigitalOcean, offer more advanced monitoring in their dashboards if you have the official Kubernetes state metrics agent installed. The agent is queried by a collector that may be installed by the cloud provider using the agent's API.

Normally, you would use the [example YAML deployment](https://github.com/kubernetes/kube-state-metrics/tree/master/examples/standard) method provided by the maintainers of the agent, but I prefer to manage deployments to K8s using Terraform to keep everything together. I created this module to avoid copying and pasting it everywhere.

## Requirements
Just a pre-configured Kubernetes provider, which will be used by this module.

## Example

This example will create a Kubernetes cluster with a single node using the [DigitalOcean](https://registry.terraform.io/providers/digitalocean/digitalocean) provider, and deploy the metrics agent provided by the module.

You can use [this referral link](https://m.do.co/c/f8ffd8a5f356) to get some free credit in DigitalOcean to play around with.

```tf
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.22.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
  }
}

# ---
# CLUSTER SETUP
# ---
resource "digitalocean_kubernetes_cluster" "cluster" {
  name   = "my-sample-cluster"
  region = "nyc1"
  version = "1.24.4-do.0"

  node_pool {
    name = "default"
    size = "s-1vcpu-2gb"

    node_count = 1
  }
}

# ---
# PROVIDER CONFIG
# ---
provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.cluster.endpoint
  token = digitalocean_kubernetes_cluster.cluster.kube_config.0.token

  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
}

# ---
# THE MODULE
# ---
module "metrics" {
  source  = "git@github.com:crookm/tf-kube-metrics.git?ref=v0.1.1" # omit '?ref=' to always use latest
}
```


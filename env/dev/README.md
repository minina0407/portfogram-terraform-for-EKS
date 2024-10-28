<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compute"></a> [compute](#module\_compute) | ../../modules/compute | n/a |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | ../../modules/load_balancer | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../modules/network | n/a |
| <a name="module_security"></a> [security](#module\_security) | ../../modules/security | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ../../modules/storage | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones | `list(string)` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region | `string` | `"ap-southeast-1"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version | `string` | `"1.27"` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | Listener port for the load balancer | `number` | n/a | yes |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Configuration for EKS node groups | <pre>map(object({<br/>        desired_size  = number<br/>        max_size      = number<br/>        min_size      = number<br/>        disk_size     = number<br/>        instance_type = string<br/>    }))</pre> | n/a | yes |
| <a name="input_private_subnets_cidr"></a> [private\_subnets\_cidr](#input\_private\_subnets\_cidr) | List of CIDR blocks for private subnets | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the project | `string` | n/a | yes |
| <a name="input_public_subnets_cidr"></a> [public\_subnets\_cidr](#input\_public\_subnets\_cidr) | List of CIDR blocks for public subnets | `list(string)` | n/a | yes |
| <a name="input_target_port"></a> [target\_port](#input\_target\_port) | Target port for the load balancer | `number` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for EKS control plane |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | EKS 클러스터 이름 |
| <a name="output_tf_state_bucket"></a> [tf\_state\_bucket](#output\_tf\_state\_bucket) | Terraform 상태 파일 버킷 이름 |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END_TF_DOCS -->
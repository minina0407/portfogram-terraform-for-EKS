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
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

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
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | 가용영역 목록 (고가용성을 위해 최소 2개 필수) | `list(string)` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS 리전 (예: ap-northeast-2, ap-southeast-1) | `string` | `"ap-northeast-2"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes 버전 (1.25 ~ 1.28 사이, 형식: 1.XX) | `string` | `"1.28"` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | 리스너 포트 (클라이언트가 연결하는 포트, 일반적으로 80 또는 443, 1-65535) | `number` | n/a | yes |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | EKS 노드 그룹 설정 맵 (각 노드 그룹별 스케일링 정책 및 인스턴스 타입 정의) | <pre>map(object({<br>    desired_size  = number # 목표 노드 수<br>    max_size      = number # 최대 노드 수<br>    min_size      = number # 최소 노드 수<br>    disk_size     = number # 디스크 크기 (GB, 최소 20GB)<br>    instance_type = string # EC2 인스턴스 타입 (예: t3.medium)<br>  }))</pre> | n/a | yes |
| <a name="input_private_subnets_cidr"></a> [private\_subnets\_cidr](#input\_private\_subnets\_cidr) | 프라이빗 서브넷 CIDR 블록 목록 (EKS 노드 그룹 등 외부에 직접 노출되지 않는 리소스용) | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | 프로젝트 이름 (리소스 이름 prefix에 사용, 소문자, 숫자, 하이픈만 허용) | `string` | n/a | yes |
| <a name="input_public_subnets_cidr"></a> [public\_subnets\_cidr](#input\_public\_subnets\_cidr) | 퍼블릭 서브넷 CIDR 블록 목록 (로드밸런서, NAT 게이트웨이 등 인터넷 접근이 필요한 리소스용) | `list(string)` | n/a | yes |
| <a name="input_target_port"></a> [target\_port](#input\_target\_port) | 대상 그룹 포트 (애플리케이션이 실제로 수신하는 포트, 1-65535) | `number` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR 블록 (예: 10.0.0.0/16) | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
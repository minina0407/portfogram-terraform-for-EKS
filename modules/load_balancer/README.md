<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | EKS cluster endpoint URL | `string` | n/a | yes |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Health check interval in seconds | `number` | `30` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | Port number for the listener | `number` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to be used for resource names | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs where the load balancer will be placed | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to all resources | `map(string)` | `{}` | no |
| <a name="input_target_port"></a> [target\_port](#input\_target\_port) | Port number for the target group | `number` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the load balancer will be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_listener_arn"></a> [listener\_arn](#output\_listener\_arn) | 리스너 ARN |
| <a name="output_load_balancer_arn"></a> [load\_balancer\_arn](#output\_load\_balancer\_arn) | 로드밸런서 ARN |
| <a name="output_load_balancer_dns_name"></a> [load\_balancer\_dns\_name](#output\_load\_balancer\_dns\_name) | 로드밸런서 DNS 이름 |
| <a name="output_load_balancer_id"></a> [load\_balancer\_id](#output\_load\_balancer\_id) | 로드밸런서 ID |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | 로드밸런서 보안 그룹 ID |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | 대상 그룹 ARN |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | 로드밸런서 Route 53 호스팅 영역 ID |
<!-- END_TF_DOCS -->
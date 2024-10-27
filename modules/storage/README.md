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
| [aws_s3_bucket.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.thanos](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.thanos](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.thanos](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.thanos](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_state_bucket_name"></a> [state\_bucket\_name](#input\_state\_bucket\_name) | Terraform 상태 파일을 저장할 S3 버킷 이름 | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | 모든 리소스에 적용될 태그 | `map(string)` | `{}` | no |
| <a name="input_thanos_bucket_name"></a> [thanos\_bucket\_name](#input\_thanos\_bucket\_name) | Thanos 메트릭을 저장할 S3 버킷 이름 | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_state_bucket_arn"></a> [state\_bucket\_arn](#output\_state\_bucket\_arn) | Terraform 상태 버킷 ARN |
| <a name="output_state_bucket_name"></a> [state\_bucket\_name](#output\_state\_bucket\_name) | Terraform 상태 버킷 이름 |
| <a name="output_state_bucket_versioning_status"></a> [state\_bucket\_versioning\_status](#output\_state\_bucket\_versioning\_status) | Terraform 상태 버킷 버저닝 상태 |
| <a name="output_thanos_bucket_arn"></a> [thanos\_bucket\_arn](#output\_thanos\_bucket\_arn) | Thanos 메트릭 버킷 ARN |
| <a name="output_thanos_bucket_name"></a> [thanos\_bucket\_name](#output\_thanos\_bucket\_name) | Thanos 메트릭 버킷 이름 |
| <a name="output_thanos_bucket_versioning_status"></a> [thanos\_bucket\_versioning\_status](#output\_thanos\_bucket\_versioning\_status) | Thanos 메트릭 버킷 버저닝 상태 |
<!-- END_TF_DOCS -->
# AWS S3 버킷 생성
resource "aws_s3_bucket" "bucket"{
  bucket = var.bucket_name  # 버킷 이름 설정, 변수로부터 가져옴
  tags = {
    Name = var.bucket_name  # 버킷에 태그 추가, 버킷 이름을 태그로 설정
  }
}


# S3 버킷의 공개 접근 차단 설정
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.bucket.id  # 차단 설정을 적용할 버킷 ID

  block_public_acls       = true    # 공개 ACLs 차단
  block_public_policy     = true    # 버킷 정책을 통한 공개 접근 차단
  ignore_public_acls      = true    # 기존 공개 ACLs 무시
  restrict_public_buckets = true    # 다른 계정의 공개 및 개인 버킷 접근 제한
}

resource "aws_dynamodb_table" "tf_lock" {
name         = "tf-state-lock"
billing_mode = "PAY_PER_REQUEST"
hash_key     = "LockID"

attribute {
name = "LockID"
type = "S"
}

tags = {
Name = "tf-state-lock-table"
}
}
# S3 버킷의 ARN을 출력
output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn  # 생성된 S3 버킷의 ARN 출력
}

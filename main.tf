locals {
  resource_prefix = "ky-tf"
}

resource "aws_s3_bucket" "static_bucket" {
 bucket = "${local.resource_prefix}-s3.sctp-sandbox.com"
 force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "enable_public_access" {
  bucket = aws_s3_bucket.static_bucket.id  
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.static_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "null_resource" "clone_git_repo" {
  provisioner "local-exec" {
    command = <<EOT
      git clone https://github.com/cloudacademy/static-website-example.git website_content
      aws s3 sync website_content s3://${aws_s3_bucket.static_bucket.id} --exclude "*.MD" --exclude ".git*" --delete 
    EOT
  }
  
  # Ensures this runs after the S3 bucket is created
  depends_on = [aws_s3_bucket.static_bucket]
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.sctp_zone.zone_id
  name = "${local.resource_prefix}-s3" 
  type = "A"

  alias {
   name = aws_s3_bucket_website_configuration.website.website_domain
   zone_id = aws_s3_bucket.static_bucket.hosted_zone_id
   evaluate_target_health = true
 }
}


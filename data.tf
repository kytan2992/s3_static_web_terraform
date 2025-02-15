data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    sid = "PublicReadGetObject"
    principals {
      type = "*"
      identifiers = [ "*" ]
    } 
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.static_bucket.arn}/*"
    ]
  }
}

data "aws_route53_zone" "sctp_zone" {
 name = "sctp-sandbox.com"
}

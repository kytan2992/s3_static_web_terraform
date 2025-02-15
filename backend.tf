terraform {
  backend "s3" {
    bucket = "ky-s3-terraform"
    key    = "ky-tf-s3-webhost.tfstate"
    region = "us-east-1"
  }
}
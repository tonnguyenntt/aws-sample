provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.aws_region
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.keypair_name
  public_key = var.keypair_public
}

terraform {
  backend "s3" {
    bucket = "goutham-terraform-state-188244334939"
    key    = "kubernetes/terraform.tfstate"
    region = "ap-south-1"
  }
}

terraform {
  required_providers {
    aws = {                               // if we want an another cloud provider then we must re initialize it.
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"            //version of terraform required

 //This is where you want to configure the remote backend so that Terraform stores the state file in S3 and uses DynamoDB for state locking.

 backend "s3" {
    bucket         = "YOUR_BUCKET_NAME"          # Replace with the name of the S3 bucket created in `remote_state`
    key            = "local_state/terraform.tfstate"  # Path to the state file in the bucket
    region         = "us-west-2"                # Replace with the region of your S3 bucket
    encrypt        = true
    dynamodb_table = "terraform-lock"           # Replace with the name of your DynamoDB table
  }
}

provider "aws" {                            // if you dont use it is fine ..not a mandatory block
  region  = "us-west-2"
}

// the above things which is written till now is constant.

// if we have to create two resources we have to create 2 resource block
resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform_Demo"
  }
}

output "ec2-public-ips" {
        value = aws_instance.app_server.public_ip
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}


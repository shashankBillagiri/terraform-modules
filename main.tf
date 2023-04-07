provider "aws" {
    region = "us-east-1"
}

# resource "<provider>_<resource_type>" "name" {
#   config options.......connection {
#     key = "value"
#     key2 = "anotehrvalue"
#   }
# }

# resource "aws_instance" "ec2Instance" {
#     #count = 4 
#     ami           = "ami-007855ac798b5175e"
#     instance_type = "t2.micro"

#  tags = {
#     Name = "created using Terraform"
#   }
# }

resource "aws_vpc" "virtualPrivateCloud" {

 #Classless Inter-Domain Routing
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "created using Terraform"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.virtualPrivateCloud.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "created using Terraform"
  }
}

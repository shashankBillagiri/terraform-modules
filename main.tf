provider "aws" {
    region = "us-east-1"
}

# resource "<provider>_<resource_type>" "name" {
#   config options.......connection {
#     key = "value"
#     key2 = "anotehrvalue"
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
  # referencing in terraform, Here we are referring to the id of vpc created above.
  vpc_id     = aws_vpc.virtualPrivateCloud.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "created using Terraform"
  }
}



# Practise Project

resource "aws_vpc" "PractiseVpc" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_internet_gateway" "PractiseInternetGateway" {
  vpc_id = aws_vpc.PractiseVpc.id
}

# this allows the traffic from subnet that we create can get out to the internet.
resource "aws_route_table" "PractiseCustomRouteTable" {
  vpc_id = aws_vpc.PractiseVpc.id

  route {
    # default route - 0.0.0.0/0 - ALl traffic is going to get sent to the internet gateway.
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.PractiseInternetGateway.id
  }

  route {
    # default route for ipv6
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.PractiseInternetGateway.id
}
}

# creating a subnet where our webserver resides.
resource "aws_subnet" "Practisesubnet" {
  vpc_id     = aws_vpc.PractiseVpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Associate subnet with Route Table
resource "aws_route_table_association" "PractiseAwsRouteTableAssosciation" {
  subnet_id      = aws_subnet.Practisesubnet.id
  route_table_id = aws_route_table.PractiseCustomRouteTable.id
}


resource "aws_security_group" "PractiseSecurityGroup" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.PractiseVpc.id

  ingress {
    description      = "Https traffic  from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    # what subnets can reach this box, we can put our own device IP adress so that only we can access it.
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  ingress {
    description      = "Http traffic  from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    # what subnets can reach this box, we can put our own device IP adress so that only we can access it.
    cidr_blocks      = ["0.0.0.0/0"]

  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "PractiseNetworkInterface" {
  subnet_id       = aws_subnet.Practisesubnet.id
  #Any IP which is subset of subnet IP range
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.PractiseSecurityGroup.id]

}

resource "aws_eip" "PractiseElasticIp" {
  vpc                       = true
  network_interface         = aws_network_interface.PractiseNetworkInterface.id
  # its going to be assosciated to teh privateIp in NetworkInterface
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.PractiseInternetGateway]

}

resource "aws_instance" "PractiseEc2Instance" {
    #count = 4  - if we specify count it creates those number of instances.
    ami           = "ami-007855ac798b5175e"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "Terraform"
    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.PractiseNetworkInterface.id
    }
    user_data = <<-EOF
               #!/bin/bash
               sudo apt update -y
               sudo apt install apache2 -y
               sudo systemctl start apache2
               sudo bash -c 'echo Helloworld> /var/www/html/index.html'
               EOF
}

output "PractiseServerPublicIP" {

  value = aws_eip.PractiseElasticIp.public_ip
  
}


output "serverPrivateIP" {
  value = aws_eip.PractiseElasticIp.private_ip

}

output "serverPrivateId" {
  value = aws_eip.PractiseElasticIp.id

}




resource "aws_vpc" "SampleVpc" {
  cidr_block = var.subnet_prefix
}


resource "aws_subnet" "SampleSubnet" {
  vpc_id     = aws_vpc.SampleVpc.id
  cidr_block = "10.0.0.0/24"
}


resource "aws_subnet" "SampleSubnet1" {
  vpc_id     = aws_vpc.SampleVpc.id
  cidr_block = var.sample_subnet[1]
}

# resource "aws_subnet" "SampleSubnet2" {
#   vpc_id     = aws_vpc.SampleVpc.id
#   cidr_block = var.sample_subnet1[1].cidr_block
#   tags = {
#     "name" = var.sample_subnet1[1].name
#   }
# }


# using DataSource

# data "aws_vpc" "PractiseDataSource" {
#    default = true
#   }


# output "PractiseDataSourceVpcId" {
#   value = data.aws_vpc.PractiseDataSource
  
# }


data "aws_vpc" "getdefaultVpc" {
  filter {
    name   = "tag:Name"
    values = ["defaultVpc"]
  }

}


output "printdefaultVpcDetails" {

  value = data.aws_vpc.getdefaultVpc

}
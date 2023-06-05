variable "subnet_prefix" {

    description = "cidr block value for vpc"
    default =  "10.0.0.0/16"
   # type
  
}



variable "sample_subnet" {

    description = "cidr block value for vpc1"
    type = list
}

variable "app_name" {

    description = "name of the application"
    type = string
    default = "terraform-modules"
}


# variable "sample_subnet1" {

#     description = "cidr block value for vpc2"
#     type = list
# }

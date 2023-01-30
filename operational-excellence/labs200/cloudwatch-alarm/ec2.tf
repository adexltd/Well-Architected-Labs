resource "aws_instance" "linux" {
  ami           = "ami-00d8a762cb0c50254"
  instance_type = "t2.micro"

  tags = {
    Name = "Demo Server"
  }
}


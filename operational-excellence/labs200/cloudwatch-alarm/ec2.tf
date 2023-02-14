resource "aws_instance" "ec2" {
  ami           = "ami-0036b4598ccd42565"
  instance_type = "t2.micro"

  tags = {
    Name = "Demo Server"
  }
}


resource "aws_instance" "main" {
  ami = data.aws_ssm_parameter.instance_ami.value
  instance_type = "t2.micro"
  key_name = "TDC-P3"
  subnet_id = aws_subnet.Public[0].id
  vpc_security_group_ids = ["sg-04d32026d5ac8e4b4", "sg-0179a6c0ad02bf95d", "sg-05ada0822c21140eb", "sg-065dd0f152d020822"]
  tags = {
    "Name" = "${var.default_tags.env}-EC2"
  }
  user_data = base64encode(file("C:/Users/vicor/OneDrive/Documents/codingstudymaterial/VETTECMATERIAL/TDC-P3/user.sh"))
}
output "ec2_ssh_command" {
  value = "ssh -i TDC-P3.pem ubuntu@ec2-${replace(aws_instance.main.public_ip,".", "-")}.compute-1.amazonaws.com"
}

resource "aws_instance" "pvtec2" {
  ami = data.aws_ssm_parameter.instance_ami.value
  instance_type = "t2.micro"
  subnet_id = aws_subnet.Private[0].id
  key_name = "TDC-P3"
  vpc_security_group_ids = ["sg-04d32026d5ac8e4b4", "sg-05ada0822c21140eb"]
  tags = {
    "Name" = "${var.default_tags.env}-PVT-EC2"
  }
    user_data = base64encode(file("C:/Users/vicor/OneDrive/Documents/codingstudymaterial/VETTECMATERIAL/TDC-P3/user.sh"))
}
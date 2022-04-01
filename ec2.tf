resource "aws_instance" "ec2-01" {
    ami = "ami-0c02fb55956c7d316"
    instance_type = "t2.micro"
    key_name = var.key_name

    network_interface {
        network_interface_id = aws_network_interface.nic-01.id
        device_index = 0 
    }

    depends_on = [aws_network_interface.nic-01]


}

resource "aws_network_interface" "nic-01" {
    subnet_id = aws_subnet.private-subnet-01.id

    tags = {
        Name = "NIC_01"
    }

    depends_on = [aws_subnet.private-subnet-01]
}

#Public web server 1
resource "aws_instance" "Public-web-server" {
    ami = data.aws_ami.amazon.id
    count = 2
    instance_type = var.web_instance_type
    availability_zone = [
        "ap-southeast-2a",
        "ap-southeast-2b"
    ][count.index]

    subnet_id = [
        "subnet-0311b82254f8e7715",
        "subnet-02ec39c1f0ef0df2e"
    ][count.index]

    associate_public_ip_address = true
    vpc_security_group_ids = [ 
        aws_security_group.WEB-security-group.id
        ]

        key_name = aws_key_pair.Project_key.key_name

        user_data = <<-EOF
                #!/bin/bash
                dnf update -y

                dnf install -y nginx 

                systemctl enable nginx
                systemctl start nginx
                
                cat> cd /usr/share/nginx/html/index.html << HTML
                <h1>This is Public web server ${count.index+1}</h1>
                HTML 
                EOF
    tags = {
      Name = "Public-WEB-${count.index+1}"
    }
}

#Private Instances

resource "aws_instance" "Private-app-server" {
    ami = data.aws_ami.amazon.id
    count = 2
    instance_type = var.web_instance_type
    availability_zone = [
        "ap-southeast-2a",
        "ap-southeast-2b"
    ][count.index]

    subnet_id = [
        "subnet-01f9b8704282df0fa",
        "subnet-094e295801dcea47b"
    ][count.index]

    vpc_security_group_ids = [ 
        aws_security_group.APP-security-group.id
        ]

        key_name = aws_key_pair.Project_key.key_name

        user_data = <<-EOF
                #!/bin/bash
                dnf update -y

                dnf install -y nginx 

                systemctl enable nginx
                systemctl start nginx

                cat > cd /usr/share/nginx/html << HTML
                <h1>This is Public app server ${count.index+1}</h1> 
                HTML
                EOF
    tags = {
      Name = "Public-APP-${count.index+1}"
    }
}

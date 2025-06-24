resource "aws_launch_template" "lt" {
    name_prefix = "swarm-"
    image_id = "ami-0f5ee92e2d63afc18"
    instance_type = var.instance_type
    key_name = var.key_name
  
    network_interfaces {
      associate_public_ip_address = false
      security_groups = [aws_security_group.alb_sg.id]
    }

    tag_specifications {
      resource_type = "instance"
      tags = {
        Role = "swarm"
      }
    }
}
resource "aws_autoscaling_group" "asg" {
  desired_capacity = 1
  min_size = var.min_size
  max_size = var.max_size
  vpc_zone_identifier = [aws_subnet.private.id]

  launch_template {
    id = aws_launch_template.lt.id
    version = "$Latest"
  }

  health_check_type = "EC2"
  health_check_grace_period = 300
 tag {
    key                 = "Name"
    value               = "Swarm-Node"
    propagate_at_launch = true
  }
}
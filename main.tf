provider "aws" {
   region     = "ap-southeast-1a"
   profile = "default"
}

resource "aws_launch_configuration" "lc" {
  name_prefix          = "${var.name}_lc"
  image_id             = "${var.ami_id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.key_name}"
  security_groups      = ["${var.security_group_ids}"]
  user_data            = "${var.user_data}"
  enable_monitoring    = "${var.enable_monitoring}"
  iam_instance_profile = "${var.iam_instance_profile}"
  associate_public_ip_address = "${var.associate_public_ip_address}"

  root_block_device {
    volume_type           = "${var.asg_root_volume_type}"
    volume_size           = "${var.asg_root_volume_size}"
    delete_on_termination = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.name}"
  vpc_zone_identifier  = ["${var.instance_subnets}"]
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.lc.name}"
  load_balancers       = ["${aws_elb.elb.id}"]
  health_check_grace_period = 300
  health_check_type         = "ELB"
  termination_policies = ["NewestInstance"]
  suspended_processes  = "${var.suspended_processes}"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.name}_asg"
    propagate_at_launch = "true"
  }

#scale up

resource "aws_autoscaling_policy" "scale-up-policy-prodwaf" {
  name                   = "scale-up-policy-prodwaf"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 150
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpualarm-up-prodwaf" {
  alarm_name          = "cpualarm-up-prodwaf"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scale-up-policy-prodmobrmsapp.arn}", "${aws_sns_topic.scaleupscaledownalerts.arn}"]
}

# scale down

resource "aws_autoscaling_policy" "scale-down-policy-prodwaf" {
  name                   = "scale-down-policy-prodwaf"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpualarm-down-prodwaf" {
  alarm_name          = "cpualarm-down-prodwaf"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "40"
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scale-down-policy-prodwaf.arn}", "${aws_sns_topic.scaleupscaledownalerts.arn}"]
}

resource "aws_sns_topic" "scaleupscaledownalerts" {
  name = "scaleupscaledownalerts"
}

resource "aws_cloudwatch_metric_alarm" "NetworkTrafficTest" {
  alarm_name                = "NetworkTrafficTest"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "NetworkIn"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "10"
  alarm_description         = "This metric monitors Incomming Network Traffic"
  insufficient_data_actions = []
  dimensions = {
    InstanceId = aws_instance.ec2.id
  }
  alarm_actions = [aws_sns_topic.AdminAlert.arn]
}
locals {
  instance_profile_name_prefix = "${var.name_prefix}-instance-profile"
  iam_role_name_prefix = "${var.name_prefix}-instance-role"
  iam_policy_name_prefix = "${var.name_prefix}-permissions"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = local.instance_profile_name_prefix
  role = aws_iam_role.workload_instance_role.name
}

resource "aws_iam_role" "workload_instance_role" {
  name_prefix = local.iam_role_name_prefix
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
         "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "AllowAssumeByEC2"
    }
  ]
}
POLICY

  force_detach_policies = true
}

# IAM Policy with SSM Session Manager permission
# Reference: https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-create-iam-instance-profile.html
resource "aws_iam_policy" "ssm_policy" {
  name_prefix = local.iam_policy_name_prefix
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSM",
      "Action": [
        "ssm:UpdateInstanceInformation",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "workload_instance_role_attachment" {
  policy_arn = aws_iam_policy.ssm_policy.arn
  role       = aws_iam_role.workload_instance_role.name
}

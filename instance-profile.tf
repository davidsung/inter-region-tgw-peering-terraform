# IAM Instance Profile
resource "aws_iam_instance_profile" "workload_instance_profile" {
  name = "workload-instance-profile"
  role = aws_iam_role.workload_instance_role.name
}

resource "aws_iam_role" "workload_instance_role" {
  name               = "workload-instance-role"
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
  name   = "SessionManagerPermissions"
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

resource "aws_iam_role_policy_attachment" "nginx_instance_role_attachment" {
  policy_arn = aws_iam_policy.ssm_policy.arn
  role       = aws_iam_role.workload_instance_role.name
}
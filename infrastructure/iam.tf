data "aws_iam_policy_document" "ec2_sts_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }

}
resource "aws_iam_role" "ec2_ssm" {
  name_prefix        = "epita-talk-ssm-"
  assume_role_policy = data.aws_iam_policy_document.ec2_sts_assume.json
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name_prefix = "epita-talk-ssm-"
  role        = aws_iam_role.ec2_ssm.name
}

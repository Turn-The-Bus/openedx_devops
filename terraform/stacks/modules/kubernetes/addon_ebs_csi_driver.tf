#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Dec-2022
#
# Create the Amazon EBS CSI driver IAM role for service accounts
# https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
#------------------------------------------------------------------------------

data "aws_iam_policy" "AmazonEBSCSIDriverPolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# 2. Create the IAM role.
resource "aws_iam_role" "AmazonEKS_EBS_CSI_DriverRole" {
  name = "AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::293205054626:oidc-provider/oidc.eks.ap-south-1.amazonaws.com/id/29C2181790F788712E6BBACEDE43DB0D"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.ap-south-1.amazonaws.com/id/29C2181790F788712E6BBACEDE43DB0D:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
})
  tags = var.tags
}

# 3. Attach the required AWS managed policy to the role 
resource "aws_iam_role_policy_attachment" "aws_ebs_csi_driver" {
  role       = aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.name
  policy_arn = data.aws_iam_policy.AmazonEBSCSIDriverPolicy.arn
}

# 5. Annotate the ebs-csi-controller-sa Kubernetes service account with the ARN of the IAM role
# 6. Restart the ebs-csi-controller deployment for the annotation to take effect
resource "null_resource" "annotate-ebs-csi-controller" {

  provisioner "local-exec" {
    command = <<-EOT
      kubectl annotate serviceaccount ebs-csi-controller-sa -n kube-system eks.amazonaws.com/role-arn=arn:aws:iam::${var.account_id}:role/${aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.name}
      kubectl rollout restart deployment ebs-csi-controller -n kube-system
      kubectl rollout restart deployment ebs-csi-controller -n kube-system
    EOT
  }

  depends_on = [
    module.eks
  ]
}

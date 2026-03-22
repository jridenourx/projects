# --- SECTION 1: NETWORK SECURITY GROUPS ---

# 1. Management Security Group 
# This allows us to access the network from your home workstation.
resource "aws_security_group" "management_sg" {
  name        = "management-sg"
  vpc_id      = aws_vpc.capstone_vpc.id
  description = "Restricts management access to my home IP"

  tags = {
    Name      = "management-sg"
    Project   = "Cloud-Security-Capstone"
    ManagedBy = "Terraform"
  }
}

# 2. Ingress Rule: Updated to use variable
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.management_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.my_ip # <--- Now uses the variable
}

# 3. Database Security Group (The Vault)
# This isolates the RDS instance and only trusts the Management SG.
resource "aws_security_group" "db_sg" {
  name        = "rds-private-sg"
  vpc_id      = aws_vpc.capstone_vpc.id
  description = "Isolates the database from the internet"

  tags = {
    Name      = "database-sg"
    Project   = "Cloud-Security-Capstone"
    ManagedBy = "Terraform"
  }
}

# 4. Ingress Rule: The Chain of Trust
# Traffic is only allowed on the MySQL port (3306) if it comes from the Management SG.
resource "aws_vpc_security_group_ingress_rule" "allow_db_access" {
  security_group_id            = aws_security_group.db_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.management_sg.id
}

# 5. Egress Rules (Outbound Traffic)
# Required so the instances can respond to requests and send logs to CloudWatch.
resource "aws_vpc_security_group_egress_rule" "mgmt_egress" {
  security_group_id = aws_security_group.management_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "db_egress" {
  security_group_id = aws_security_group.db_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = var.my_ip
}

# --- SECTION 2: DATA ENCRYPTION (KMS) ---

# 6. KMS Key for RDS Encryption
# This key performs AES-256 storage encryption on the database.
resource "aws_kms_key" "rds_key" {
  description             = "KMS Key for Capstone RDS Storage Encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true 

  tags = {
    Name      = "capstone-rds-key"
    Project   = "Cloud-Security-Capstone"
    ManagedBy = "Terraform"
  }
}

# 7. KMS Alias
resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/capstone-rds-encryption-key"
  target_key_id = aws_kms_key.rds_key.key_id
}

# --- SECTION 3: IDENTITY & MONITORING (IAM) ---

# 8. IAM Role for Enhanced Monitoring
# This allows the RDS instance to send internal metrics to CloudWatch.
resource "aws_iam_role" "rds_monitoring_role" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
    }]
  })
}

# 9. Attach the policy to the role
resource "aws_iam_role_policy_attachment" "rds_monitoring_attachment" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
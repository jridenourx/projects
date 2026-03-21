# --- SECTION 1: NETWORK SECURITY GROUPS ---

# 1. Management Security Group 
# This allows us to access the network from my home workstation.
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

# 2. Ingress Rule: Restricted SSH Access
# Using the /32 CIDR block ensures ONLY my specific IP can connect.
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.management_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "73.31.75.0/32" 
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
# Traffic is only allowed on the MySQL port (3306) if it comes from the Lobby.
resource "aws_vpc_security_group_ingress_rule" "allow_db_access" {
  security_group_id            = aws_security_group.db_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.management_sg.id
}

# --- SECTION 2: DATA ENCRYPTION (KMS) ---

# 5. KMS Key for RDS Encryption
# This key will be used to perform AES-256 storage encryption on the database.
resource "aws_kms_key" "rds_key" {
  description             = "KMS Key for Capstone RDS Storage Encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true # Fulfills the requirement for automated rotation

  tags = {
    Name      = "capstone-rds-key"
    Project   = "Cloud-Security-Capstone"
    ManagedBy = "Terraform"
  }
}

# 6. KMS Alias (A human-readable name for the key)
resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/capstone-rds-encryption-key"
  target_key_id = aws_kms_key.rds_key.key_id
}
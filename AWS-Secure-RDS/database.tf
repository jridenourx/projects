# --- SECTION 1: DATABASE NETWORKING ---

# 1. DB Subnet Group
resource "aws_db_subnet_group" "capstone_db_subnet_group" {
  name       = "capstone-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name      = "rds-private-subnet-group"
    Project   = "Cloud-Security-Capstone"
    ManagedBy = "Terraform"
  }
}

# --- SECTION 2: THE ENCRYPTED RDS INSTANCE ---

resource "aws_db_instance" "capstone_db" {
  identifier           = "hardened-capstone-db" 
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro" 
  db_name              = "capstonedb"
  
  # Using Variables for Credentials
  username             = var.db_username
  password             = var.db_password # <--- Now uses the variable
  
  db_subnet_group_name   = aws_db_subnet_group.capstone_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true 
  publicly_accessible    = false 

  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds_key.arn 

  # Identity & Monitoring
  iam_database_authentication_enabled = true
  monitoring_interval                 = 60
  monitoring_role_arn                 = aws_iam_role.rds_monitoring_role.arn

  tags = {
    Name      = "hardened-capstone-db"
    Project   = "Cloud-Security-Capstone"
  }
}
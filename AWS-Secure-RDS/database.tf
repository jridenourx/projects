# --- SECTION 1: DATABASE NETWORKING ---

# 1. DB Subnet Group
# This tells AWS exactly which subnets the database is allowed to live in.
# I am selecting ONLY my private subnets to ensure the RDS is not public.
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

# 2. RDS MySQL Instance
# This is the Vault that stores sensitive data.
resource "aws_db_instance" "capstone_db" {
  identifier           = "hardened-capstone-db" # 
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro" # Free Tier eligible
  db_name              = "capstonedb"
  username             = "admin"
  password             = "Password123!" 
  
  # Network & Security Links
  db_subnet_group_name   = aws_db_subnet_group.capstone_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true # Set to false for production environments
  publicly_accessible    = false # Fulfills the requirement for network isolation

  # Encryption Link 
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds_key.arn # Links the key made in security.tf

  tags = {
    Name      = "hardened-capstone-db"
    Project   = "Cloud-Security-Capstone"
    ManagedBy = "Terraform"
  }
}
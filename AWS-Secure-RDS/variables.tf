variable "db_password" {
  description = "The master password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "my_ip" {
  description = "My current public IP for SSH and DB access (e.g., 73.31.75.0/32)"
  type        = string
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}
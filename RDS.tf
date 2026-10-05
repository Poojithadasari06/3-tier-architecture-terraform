#RDS subnet group

resource "aws_db_subnet_group" "DB-subnet-group" {
  name = "project-database-sg"

  subnet_ids = [
    aws_subnet.Private-subnet-DB-1.id,
    aws_subnet.Private-subnet-DB-2.id
  ]

  tags = {
    Name = "DB-Subnet-group"
  }
}

#RDS 

resource "aws_db_instance" "projectdb1" {
  identifier = "project-database"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "projectdb"
  username = "admin"
  password = var.password

  db_subnet_group_name = aws_db_subnet_group.DB-subnet-group.name

  vpc_security_group_ids = [
    aws_security_group.DB-security-group.id
  ]

  publicly_accessible = false

  multi_az = false

  backup_retention_period = 7

  skip_final_snapshot = true

  deletion_protection = false

  tags = {
    Name = "Project-RDS"
  }
}

#read replica
resource "aws_db_instance" "project_read_replica" {
  identifier = "three-tier-read-replica"

  replicate_source_db = aws_db_instance.projectdb1.identifier

  instance_class = "db.t3.micro"

  publicly_accessible = false

  vpc_security_group_ids = [
    aws_security_group.DB-security-group.id
  ]

  skip_final_snapshot = true

  tags = {
    Name = "Read-Replica"
  }
}

#output block

output "rds_endpoint" {
  value = aws_db_instance.projectdb1.endpoint
}
output "read_replica_endpoint" {
  value = aws_db_instance.project_read_replica.endpoint
}
resource "aws_instance" "mongo_master" {
  ami           = "ami-0e982735e36f10ca7"
  instance_type = "t2.micro"
  key_name      = var.key_pair_name
  subnet_id     = aws_subnet.public_subnet_a.id
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]

  tags = {
    Name = "MongoMaster"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "Configuring MongoDB as Master"
              sudo sed -i 's/#replication:/replication:\\n  replSetName: "rs0"/' /etc/mongod.conf
              sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
              sudo systemctl restart mongod
              mongosh --eval 'rs.initiate()'
              EOF
}

resource "aws_instance" "mongo_replicaset" {
  ami           = "ami-0e982735e36f10ca7"
  instance_type = "t2.micro"
  key_name      = var.key_pair_name
  subnet_id     = aws_subnet.public_subnet_b.id
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]

  tags = {
    Name = "MongoReplica"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "Configuring MongoDB as Replica Set"
              sudo sed -i 's/#replication:/replication:\\n  replSetName: "rs0"/' /etc/mongod.conf
              sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
              sudo systemctl restart mongod
              EOF
}


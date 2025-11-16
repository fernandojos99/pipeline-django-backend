
# ==========================================
# Usar una VPC existente
# ==========================================
data "aws_vpc" "selected" {
  id = aws_vpc.vpc_terraform.id # ID de tu VPC existente
}

# ==========================================
# Usar una subred existente
# ==========================================
data "aws_subnet" "selected" {
  id = aws_subnet.subnet_terraform.id  # ID de la subred donde crearás la instancia
}

# ==========================================
# Security Group (frontend)
# ==========================================
resource "aws_security_group" "ssh_access" {
  name        = "allow_ssh"
  description = "Permitir acceso SSH"
  vpc_id      = data.aws_vpc.selected.id

  # Para permitir ssh
  # ingress {
  #   description = "SSH desde tu IP"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  # }


  # Puerto 3000 abierto solo para el security group del ALB
  ingress {
    description = "Frontend en puerto 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"] # Permite el acceso a todo el intenet 
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Pendiente corrigir esto porque el backend lo tengo abierto al mundo
  ingress {
    description = "Permitir acceso al puerto 8000"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # o tu rango
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}







# Detectar tu IP pública automáticamente
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}




# ==========================================
# Creacion del ROL
# ==========================================

# Se crea un rol para poder descargar imagenes
resource "aws_iam_role" "ec2_role" {
  name = "ec2-ecr-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-access-profile"
  role = aws_iam_role.ec2_role.name
}







# ==========================================
# Instancia EC2  backend
# ==========================================
resource "aws_instance" "bd_ec2_terraform" {
  ami           = "ami-0cae6d6fe6048ca2c"  # AMI de Amazon Linux 2 (usa una válida en tu región)
  instance_type = "t2.micro"

  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  key_name               = "llave_manual"  
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name 

  tags = {
    Name = "bd_ec2_terraform"
  }
    # El siguiente atributo es para que se hagan de nuevo todos los cambios 
    user_data_replace_on_change = true

    # Script que funciona solo una vez (al inicio de la instancia)
      user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker

    # Login a ECR
    aws ecr get-login-password --region us-east-1 \
    | docker login --username AWS --password-stdin 586017285275.dkr.ecr.us-east-1.amazonaws.com

    # Pull de la imagen
    docker pull 586017285275.dkr.ecr.us-east-1.amazonaws.com/practica4backend:3.0.0

    # Ejecutar contenedor
    docker run -d -p 8000:8000 586017285275.dkr.ecr.us-east-1.amazonaws.com/practica4backend:3.0.0
    EOF



}


# ==========================================
# Elastic IP y asociación
# ==========================================
resource "aws_eip" "eip_terraform_2" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_terraform_assoc_2" {
  instance_id   = aws_instance.bd_ec2_terraform.id
  allocation_id = aws_eip.eip_terraform_2.id
}






# ==========================================
# Elastic IP 
# ==========================================
resource "aws_eip" "eip_terraform" {
  domain = "vpc"
}



# ==========================================
# Instancia EC2 Frontend
# ==========================================



resource "aws_instance" "ec2_terraform" {
  ami           = "ami-0cae6d6fe6048ca2c"  # AMI de Amazon Linux 2 (usa una válida en tu región)
  instance_type = "t2.micro"

  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  key_name               = "llave_manual"  
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name 

  tags = {
    Name = "ServidorTerraform"
  }

    user_data_replace_on_change = true

      user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker

    # Login a ECR
    aws ecr get-login-password --region us-east-1 \
    | docker login --username AWS --password-stdin 586017285275.dkr.ecr.us-east-1.amazonaws.com

    # Pull de la imagen
    #docker pull $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$TAG

    docker pull 586017285275.dkr.ecr.us-east-1.amazonaws.com/frontend4:7.0.0

    # Ejecutar contenedor
    #docker run -d -p 80:3000 $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$TAG
    docker run -d -p 3000:3000  -e REACT_APP_API_BASE_URL=http://${aws_eip.eip_terraform_2.public_ip}:8000/api   586017285275.dkr.ecr.us-east-1.amazonaws.com/frontend4:7.0.0
    EOF


}




# ==========================================
#  asociación
# ==========================================

resource "aws_eip_association" "eip_terraform_assoc" {
  instance_id   = aws_instance.ec2_terraform.id
  allocation_id = aws_eip.eip_terraform.id
}







# ==========================================
#  ALB 
# ==========================================
 



# Esto busca las  subredes que se tengan en esa VPC , puede haber evitado esto al 
# saber cual eran los id de las subredes que se han hecho
data "aws_subnets" "default" {
   filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc_terraform.id]
  }
}





# ============================================================
# Security Group para el ALB (permite HTTP y HTTPS desde internet)
# ============================================================

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  # vpc_id      = data.aws_vpc.default.id
  vpc_id   = data.aws_vpc.selected.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Despues checar esta forma de hacer el sg para varias instancias 
# ===========================================================
# Security Group para las instancias (sólo permite tráfico desde el ALB)
# ============================================================

# Por el momento lo dejo comentado pero tengo que rescatar la parte de security_groups (para restringir el acceso de intenet)
# resource "aws_security_group" "instance_sg" {
#   name        = "instance-sg"
#   description = "Allow traffic only from ALB"
#   # vpc_id      = data.aws_vpc.default.id
#   vpc_id   = data.aws_vpc.selected.id
#   ingress {
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [aws_security_group.alb_sg.id]
#     description     = "Allow HTTP from ALB"
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


# ===========================================================
# El ALB
# ============================================================
# Application Load Balancer (publico)
resource "aws_lb" "app" {
  name               = "example-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = slice(data.aws_subnets.default.ids, 0, 2) # usa las primeras 2 subnets públicas

  enable_deletion_protection = false
  idle_timeout               = 60
  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Target Group (tipo instance)
resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  #port     = 80  # traia este puerto inicialmente 
  # Pero el puerto donde corre el frontend es el siguiente:
  port     = 3000
  protocol = "HTTP"
  # vpc_id   = data.aws_vpc.default.id
  vpc_id   = data.aws_vpc.selected.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener HTTP 80 -> target group
#Es un proceso dentro del ALB que escucha en un puerto (e.g. 80 o 443)
# y con base en reglas decide hacia dónde mandar el tráfico.

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Lanzamos N instancias EC2 sencillas (investigar despues esto para poder crear varias instancias al mismo tiempo)
# resource "aws_instance" "web" {
#   count         = var.instance_count
#   ami           = data.aws_ami.amazon_linux.id
#   instance_type = var.instance_type
#   subnet_id     = element(slice(data.aws_subnets.default.ids, 0, 2), count.index)
#   vpc_security_group_ids = [aws_security_group.instance_sg.id]

#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello from Terraform ALB example" > /var/www/html/index.html
#               yum install -y httpd
#               systemctl enable httpd
#               systemctl start httpd
#               EOF

#   tags = {
#     Name = "web-${count.index}"
#   }
# }


# Adjuntar cada instancia al target group
resource "aws_lb_target_group_attachment" "att" {
  # El count es necesario cuando se usan muchas instancias (yo solo tengo una ahorita)
  #count            = var.instance_count
  target_group_arn = aws_lb_target_group.web_tg.arn
  #target_id        = aws_instance.web[count.index].id
  target_id        = aws_instance.ec2_terraform.id
  # El puerto no es tan necesario aqui
  #port             = 80
}



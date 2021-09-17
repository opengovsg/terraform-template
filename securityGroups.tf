resource "aws_security_group" "lb" {
  name        = "starter-kit-lb"
  description = "Allow inbound traffic only from cloudflare IPs"
  vpc_id      = module.vpc.vpc_id

  ingress = [
    # allow all cloudflare IPs
  ]

  egress = [
    {
      description      = "Allow outbound HTTP traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "Allow outbound HTTP traffic"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
    Name = "starter-kit-lb"
  }
}

resource "aws_security_group" "ec2" {
  name        = "starter-kit-ec2"
  description = "Allow inbound traffic only from load balancer"
  vpc_id      = module.vpc.vpc_id
  ingress = [
    {
      description      = "Allow traffic from load balancer"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      security_groups  = [aws_security_group.lb.id]
      cidr_blocks      = null
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      self             = null
    },
    {
      description      = "Allow traffic from load balancer"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      security_groups  = [aws_security_group.lb.id]
      cidr_blocks      = null
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      self             = null
    }
  ]

  egress = [
    {
      description      = "Allow all outbound traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
    Name = "starter-kit-ec2"
  }
}
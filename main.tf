module "database" {
  source = "./modules/database"

  vpc_id                    = module.networking.vpc_id
  public_subnet_cidr_block  = module.networking.public_subnet_cidr_block
  private_subnet_cidr_block = module.networking.private_subnet_cidr_block
  private_subnet_id         = module.networking.private_subnet_id
  ami_id                    = data.aws_ami.debian_amd64.id
  key_name                  = aws_key_pair.nodes_key_pair.key_name

  depends_on = [
    data.aws_ami.debian_amd64,
    module.networking
  ]
}

module "master" {
  source = "./modules/master"

  vpc_id                    = module.networking.vpc_id
  public_subnet_cidr_block  = module.networking.public_subnet_cidr_block
  private_subnet_cidr_block = module.networking.private_subnet_cidr_block
  private_subnet_id         = module.networking.private_subnet_id
  k3s_db_private_ip         = module.database.k3s-db_private_ip
  ami_id                    = data.aws_ami.debian_amd64.id
  key_name                  = aws_key_pair.nodes_key_pair.key_name
  k3s_master_nodes_token    = random_uuid.master_node_token.result

  depends_on = [
    module.database
  ]
}

module "load-balancer" {
  source = "./modules/load-balancer"

  vpc_id                    = module.networking.vpc_id
  public_subnet_cidr_block  = module.networking.public_subnet_cidr_block
  private_subnet_cidr_block = module.networking.private_subnet_cidr_block
  private_subnet_id         = module.networking.private_subnet_id
  k3s_master_1_private_ip   = module.master.k3s-master-1_private_ip
  k3s_master_2_private_ip   = module.master.k3s-master-2_private_ip
  ami_id                    = data.aws_ami.debian_amd64.id
  key_name                  = aws_key_pair.nodes_key_pair.key_name

  depends_on = [
    module.master
  ]
}

module "worker" {
  source = "./modules/worker"

  vpc_id                   = module.networking.vpc_id
  public_subnet_cidr_block = module.networking.public_subnet_cidr_block
  private_subnet_id        = module.networking.private_subnet_id
  k3s_lb_private_ip        = module.load-balancer.k3s-lb_private_ip
  ami_id                   = data.aws_ami.debian_amd64.id
  key_name                 = aws_key_pair.nodes_key_pair.key_name
  k3s_master_nodes_token   = random_uuid.master_node_token.result

  depends_on = [
    module.load-balancer
  ]
}

module "networking" {
  source = "./modules/networking"

}

module "bastion" {
  source = "./modules/bastion"

  vpc_id                  = module.networking.vpc_id
  public_ip               = data.http.public_ip.response_body
  public_subnet_id        = module.networking.public_subnet_id
  k3s_master_1_private_ip = module.master.k3s-master-1_private_ip
  k3s_master_2_private_ip = module.master.k3s-master-2_private_ip
  k3s_worker_1_private_ip = module.worker.k3s-worker-1_private_ip
  k3s_worker_2_private_ip = module.worker.k3s-worker-2_private_ip
  k3s_lb_private_ip       = module.load-balancer.k3s-lb_private_ip
  k3s_db_private_ip       = module.database.k3s-db_private_ip
  ami_id                  = data.aws_ami.debian_amd64.id
  key_name                = aws_key_pair.nodes_key_pair.key_name

  depends_on = [
    module.worker
  ]
}

output "k3s_db_private_ip" {
  description = "DB Private IP"
  value       = module.database.k3s-db_private_ip
}

output "k3s_master_1_private_ip" {
  description = "Master-1 Private IP"
  value       = module.master.k3s-master-1_private_ip
}

output "k3s_master_2_private_ip" {
  description = "Master-2 Private IP"
  value       = module.master.k3s-master-2_private_ip
}

output "k3s_worker_1_private_ip" {
  description = "Worker-1 Private IP"
  value       = module.worker.k3s-worker-1_private_ip
}

output "k3s_worker_2_private_ip" {
  description = "Worker-2 Private IP"
  value       = module.worker.k3s-worker-2_private_ip
}

output "k3s_lb_private_ip" {
  description = "LB Private IP"
  value       = module.load-balancer.k3s-lb_private_ip
}

output "k3s_bastion_public_ip" {
  description = "Bastion Public IP"
  value       = module.bastion.k3s-bastion_public_ip
}

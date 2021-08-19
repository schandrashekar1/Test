#Create Spoke VNET
resource "aviatrix_vpc" "san-spoke1-vnet" {
  cloud_type           = 8
  account_name         = var.azure_account
  region               = "Central US"
  name                 = "san-spoke1-vnet"
  cidr                 = "10.51.150.0/24"
  aviatrix_firenet_vpc = false
}

#Create Transit Vnet
resource "aviatrix_vpc" "san-transit-vnet" {
  cloud_type           = 8
  account_name         = var.azure_account
  region               = "Central US"
  name                 = "san-transit-vnet"
  cidr                 = "10.51.151.0/23"
  aviatrix_firenet_vpc = true
}

#create Spoke Gateway
resource "aviatrix_spoke_gateway" "san-spoke1-agw" {
  cloud_type                        = 8
  account_name                      = var.azure_account
  gw_name                           = "san-spoke1-agw"
  vpc_id                            =  aviatrix_vpc.san-spoke1-vnet.vpc_id
  vpc_reg                           = "Central US"
  gw_size                           = "Standard_B1ms"
  subnet                            = aviatrix_vpc.san-spoke1-vnet.public_subnets[0].cidr
  zone                              = "az-1"
  single_ip_snat                    = false
  enable_active_mesh                = true
  manage_transit_gateway_attachment = false
  single_az_ha                      = true
  ha_subnet                         = aviatrix_vpc.san-spoke1-vnet.public_subnets[1].cidr
  ha_zone                           = "az-2"
  ha_gw_size                        = "Standard_B1ms"
}

#Create Tranist Gateway
resource "aviatrix_transit_gateway" "san-transit-agw" {
  cloud_type                        = 8
  account_name                      = var.azure_account
  gw_name                           = "san-transit-agw"
  vpc_id                            =  aviatrix_vpc.san-transit-vnet.vpc_id
  vpc_reg                           = "Central US"
  gw_size                           = "Standard_B1ms"
  subnet                            = aviatrix_vpc.san-transit-vnet.public_subnets[0].cidr
  zone                              = "az-1"
  single_ip_snat                    = false
  enable_active_mesh                = true
  enable_transit_firenet             = true
  single_az_ha                      = true
  ha_subnet                         = aviatrix_vpc.san-transit-vnet.public_subnets[1].cidr
  ha_zone                           = "az-2"
  ha_gw_size                        = "Standard_B1ms"
}

#Connect Spoke Gateway to Transit Gateway
resource "aviatrix_spoke_transit_attachment" "san-spoke-transit-attachment" {
     spoke_gw_name   = aviatrix_spoke_gateway.san-spoke1-agw.gw_name
     transit_gw_name = aviatrix_transit_gateway.san-transit-agw.gw_name
}

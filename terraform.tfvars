web_server_location         = "uksouth"
web_server_rg               = "web-rg"
resource_prefix             = "web-server"
web_server_address_space    = "1.0.0.0/22"
web_server_address_prefix   = "1.0.1.0/24"
web_server_name             = "web"
environment                 = "development"
web_server_count            = 2
web_server_subnets          = {
    web-server              = "1.0.1.0/24"
    AzureBastionSubnet      = "1.0.2.0/24"
}

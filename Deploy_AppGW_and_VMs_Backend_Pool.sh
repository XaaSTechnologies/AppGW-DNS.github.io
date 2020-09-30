# Script to create Application Gateway and Backend Pool Virtual Machines (VMs) - VM-01, VM-02, VM-03

az group create \
--name RG-13-DNS \
--location westeurope

az network vnet create \
--resource-group RG-13-DNS \
--name AZ104-vNET \
--address-prefix 10.0.0.0/16 \
--subnet-name APPGW-SUBNET \
--subnet-prefix 10.0.0.0/24

az network vnet subnet create \
--address-prefixes 10.0.1.0/24 \
--name BACKEND-SUBNET \
--vnet-name AZ104-vNET \
--resource-group RG-13-DNS

# NSG for VM-01
az network nsg create \
  --resource-group RG-13-DNS \
  --name NSG-VM-01

az network nsg rule create \
  --resource-group RG-13-DNS \
  --name NSG-VM-01-ALLOW-HTTP \
  --nsg-name NSG-VM-01 \
  --protocol tcp \
  --direction inbound \
  --source-address-prefix '*' \
  --source-port-range '*' \
  --destination-address-prefix 'VirtualNetwork' \
  --destination-port-range 80 \
  --access allow \
  --priority 200

az network nsg rule create \
  --resource-group RG-13-DNS \
  --name NSG-VM-01-ALLOW-SSH \
  --nsg-name NSG-VM-01\
  --protocol tcp \
  --direction inbound \
  --source-address-prefix '*' \
  --source-port-range '*' \
  --destination-address-prefix 'VirtualNetwork' \
  --destination-port-range 22 \
  --access allow \
  --priority 100

# Deploy VM-01

az vm create \
  --resource-group RG-13-DNS \
  --name VM-01 \
  --admin-username adminuser \
  --admin-password adminadmin123! \
  --image UbuntuLTS \
  --vnet-name AZ104-vNET \
  --nsg NSG-VM-01 \
  --subnet BACKEND-SUBNET

az vm extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --vm-name VM-01 \
  --resource-group RG-13-DNS \
  --settings '{"commandToExecute":"apt-get -y update && apt-get -y install apache2 && rm -rf /var/www/html && git clone https://github.com/XaaSTechnologies/AppGw-Default-Web-Page.github.io.git /var/www/html/"}'

# NSG for VM-02
az network nsg create \
  --resource-group RG-13-DNS \
  --name NSG-VM-02

az network nsg rule create \
  --resource-group RG-13-DNS \
  --name NSG-VM-02-ALLOW-HTTP \
  --nsg-name NSG-VM-02 \
  --protocol tcp \
  --direction inbound \
  --source-address-prefix '*' \
  --source-port-range '*' \
  --destination-address-prefix 'VirtualNetwork' \
  --destination-port-range 80 \
  --access allow \
  --priority 200

az network nsg rule create \
  --resource-group RG-13-DNS \
  --name NSG-VM-02-ALLOW-SSH \
  --nsg-name NSG-VM-02\
  --protocol tcp \
  --direction inbound \
  --source-address-prefix '*' \
  --source-port-range '*' \
  --destination-address-prefix 'VirtualNetwork' \
  --destination-port-range 22 \
  --access allow \
  --priority 100

# Deploy VM-02

az vm create \
  --resource-group RG-13-DNS \
  --name VM-02 \
  --admin-username adminuser \
  --admin-password adminadmin123! \
  --image UbuntuLTS \
  --vnet-name AZ104-vNET \
  --nsg NSG-VM-02 \
  --subnet BACKEND-SUBNET

az vm extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --vm-name VM-02 \
  --resource-group RG-13-DNS \
  --settings '{"commandToExecute":"apt-get -y update && apt-get -y install apache2 && rm -rf /var/www/html && git clone https://github.com/XaaSTechnologies/AppGw-Images-Web-Server.github.io.git /var/www/html/images”}’


# NSG for VM-03
az network nsg create \
  --resource-group RG-13-DNS \
  --name NSG-VM-03

az network nsg rule create \
  --resource-group RG-13-DNS \
  --name NSG-VM-03-ALLOW-HTTP \
  --nsg-name NSG-VM-03 \
  --protocol tcp \
  --direction inbound \
  --source-address-prefix '*' \
  --source-port-range '*' \
  --destination-address-prefix 'VirtualNetwork' \
  --destination-port-range 80 \
  --access allow \
  --priority 200

az network nsg rule create \
  --resource-group RG-13-DNS \
  --name NSG-VM-03-ALLOW-SSH \
  --nsg-name NSG-VM-03\
  --protocol tcp \
  --direction inbound \
  --source-address-prefix '*' \
  --source-port-range '*' \
  --destination-address-prefix 'VirtualNetwork' \
  --destination-port-range 22 \
  --access allow \
  --priority 100

# Deploy VM-03

az vm create \
  --resource-group RG-13-DNS \
  --name VM-03 \
  --admin-username adminuser \
  --admin-password adminadmin123! \
  --image UbuntuLTS \
  --vnet-name AZ104-vNET \
  --nsg NSG-VM-03 \
  --subnet BACKEND-SUBNET

az vm extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --vm-name VM-03 \
  --resource-group RG-13-DNS \
  --settings '{"commandToExecute":"apt-get -y update && apt-get -y install apache2 && rm -rf /var/www/html && git clone https://github.com/XaaSTechnologies/AppGw-Video-Web-Server.github.io.git /var/www/html/video”}’

# Deploy Application Gateway

az network public-ip create \
  --resource-group RG-13-DNS \
  --name AppGW-PIP \
  --allocation-method Static \
  --sku Standard

az network application-gateway create \
  --name APPGW \
  --location westeurope \
  --resource-group RG-13-DNS \
  --vnet-name AZ104-vNET \
  --subnet APPGW-SUBNET \
  --capacity 2 \
  --sku Standard_v2 \
  --http-settings-cookie-based-affinity Disabled \
  --frontend-port 80 \
  --http-settings-port 80 \
  --http-settings-protocol Http \
  --public-ip-address AppGW-PIP

az network application-gateway address-pool create \
  --gateway-name APPGW \
  --resource-group RG-13-DNS \
  --name IMAGES-BACKEND-POOL

az network application-gateway address-pool create \
  --gateway-name APPGW \
  --resource-group RG-13-DNS \
  --name VIDEO-BACKEND-POOL

az network application-gateway frontend-port create \
  --port 8080 \
  --gateway-name APPGW \
  --resource-group RG-13-DNS \
  --name FRONTEND-PORT-8080

az network application-gateway http-listener create \
  --name BACKEND-LISTENER \
  --frontend-ip appGatewayFrontendIP \
  --frontend-port FRONTEND-PORT-8080 \
  --resource-group RG-13-DNS \
  --gateway-name APPGW


az network application-gateway url-path-map create \
  --gateway-name APPGW \
  --name myPathMap \
  --paths /images/* \
  --resource-group RG-13-DNS \
  --address-pool IMAGES-BACKEND-POOL \
  --default-address-pool appGatewayBackendPool \
  --default-http-settings appGatewayBackendHttpSettings \
  --http-settings appGatewayBackendHttpSettings \
  --rule-name IMAGES-PATH-RULE

az network application-gateway url-path-map rule create \
  --gateway-name APPGW \
  --name IMAGES-PATH-RULE \
  --resource-group RG-13-DNS \
  --path-map-name myPathMap \
  --paths /video/* \
  --address-pool VIDEO-BACKEND-POOL

az network application-gateway rule create \
  --gateway-name APPGW \
  --name rule2 \
  --resource-group RG-13-DNS \
  --http-listener BACKEND-LISTENER \
  --rule-type PathBasedRouting \
  --url-path-map myPathMap \
  --address-pool appGatewayBackendPool


#Add VMs to backend pools

az network application-gateway address-pool update -g RG-13-DNS --gateway-name APPGW \ 
-n appGatewayBackendPool --servers 10.0.1.4

az network application-gateway address-pool update -g RG-13-DNS --gateway-name APPGW \
-n IMAGES-BACKEND-POOL --servers 10.0.1.5

az network application-gateway address-pool update -g RG-13-DNS --gateway-name APPGW \
-n VIDEO-BACKEND-POOL --servers 10.0.1.6

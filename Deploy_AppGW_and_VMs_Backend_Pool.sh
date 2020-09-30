az group create --name RG-13-DNS --location westeurope

az network vnet create \
  --name myVNet \
  --resource-group RG-13-DNS \
  --location westeurope \
  --address-prefix 10.0.0.0/16 \
  --subnet-name myAGSubnet \
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create \
  --name myBackendSubnet \
  --resource-group RG-13-DNS \
  --vnet-name myVNet \
  --address-prefix 10.0.2.0/24

az network public-ip create \
  --resource-group RG-13-DNS \
  --name myAGPublicIPAddress \
  --allocation-method Static \
  --sku Standard

az network application-gateway create \
  --name myAppGateway \
  --location westeurope \
  --resource-group RG-13-DNS \
  --vnet-name myVNet \
  --subnet myAGsubnet \
  --capacity 2 \
  --sku Standard_v2 \
  --http-settings-cookie-based-affinity Disabled \
  --frontend-port 80 \
  --http-settings-port 80 \
  --http-settings-protocol Http \
  --public-ip-address myAGPublicIPAddress

az network application-gateway address-pool create \
  --gateway-name myAppGateway \
  --resource-group RG-13-DNS \
  --name imagesBackendPool

az network application-gateway address-pool create \
  --gateway-name myAppGateway \
  --resource-group RG-13-DNS \
  --name videoBackendPool

az network application-gateway frontend-port create \
  --port 8080 \
  --gateway-name myAppGateway \
  --resource-group RG-13-DNS \
  --name port8080

az network application-gateway http-listener create \
  --name backendListener \
  --frontend-ip appGatewayFrontendIP \
  --frontend-port port8080 \
  --resource-group RG-13-DNS \
  --gateway-name myAppGateway

az network application-gateway url-path-map create \
  --gateway-name myAppGateway \
  --name myPathMap \
  --paths /images/* \
  --resource-group RG-13-DNS \
  --address-pool imagesBackendPool \
  --default-address-pool appGatewayBackendPool \
  --default-http-settings appGatewayBackendHttpSettings \
  --http-settings appGatewayBackendHttpSettings \
  --rule-name imagePathRule

az network application-gateway url-path-map rule create \
  --gateway-name myAppGateway \
  --name videoPathRule \
  --resource-group RG-13-DNS \
  --path-map-name myPathMap \
  --paths /video/* \
  --address-pool videoBackendPool

az network application-gateway rule create \
  --gateway-name myAppGateway \
  --name rule2 \
  --resource-group RG-13-DNS \
  --http-listener backendListener \
  --rule-type PathBasedRouting \
  --url-path-map myPathMap \
  --address-pool appGatewayBackendPool



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
  --vnet-name myVNet \
  --nsg NSG-VM-01 \
  --subnet myBackendSubnet

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
  --vnet-name myVNet \
  --nsg NSG-VM-02 \
  --subnet myBackendSubnet

az vm extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --vm-name VM-02 \
  --resource-group RG-13-DNS \
  --settings '{"commandToExecute":"apt-get -y update && apt-get -y install apache2 && rm -rf /var/www/html && git clone https://github.com/XaaSTechnologies/AppGw-Images-Web-Server.github.io.git /var/www/html/images"}'


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
  --vnet-name myVNet \
  --nsg NSG-VM-03 \
  --subnet myBackendSubnet

az vm extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --vm-name VM-03 \
  --resource-group RG-13-DNS \
  --settings '{"commandToExecute":"apt-get -y update && apt-get -y install apache2 && rm -rf /var/www/html && git clone https://github.com/XaaSTechnologies/AppGw-Video-Web-Server.github.io.git /var/www/html/video"}'


az network application-gateway address-pool update -g RG-13-DNS --gateway-name myAppGateway \
-n appGatewayBackendPool --servers 10.0.2.4

az network application-gateway address-pool update -g RG-13-DNS --gateway-name myAppGateway \
-n imagesBackendPool --servers 10.0.2.5

az network application-gateway address-pool update -g RG-13-DNS --gateway-name myAppGateway \
-n videoBackendPool --servers 10.0.2.6

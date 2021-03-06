include .env
export

ssh:
	cd 
	ssh $(SSH_STRING)

# initializing VPN server
init: 
	tar -zcvf archive.tar.gz vpn
	scp archive.tar.gz $(SSH_STRING):/root/
	rm archive.tar.gz
	ssh $(SSH_STRING) "tar -zxvf archive.tar.gz; cd vpn; docker-compose run --rm openvpn ovpn_genconfig -u $(VPN_SERVER)"
	ssh $(SSH_STRING) "cd vpn; docker-compose run --rm openvpn ovpn_initpki; docker-compose up -d openvpn"


# Create and download a client .ovpn file. The file is opened in OpenVPN Connect software.
client:
	ssh $(SSH_STRING) "cd vpn; docker-compose run --rm openvpn easyrsa build-client-full $(CLIENTNAME) nopass; docker-compose run --rm openvpn ovpn_getclient $(CLIENTNAME) > $(CLIENTNAME).ovpn"
	scp $(SSH_STRING):/root/vpn/$(CLIENTNAME).ovpn .
	ssh $(SSH_STRING) "cd vpn; rm /root/vpn/$(CLIENTNAME).ovpn"
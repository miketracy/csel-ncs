ufw allow in on lo
ufw allow out on lo
ufw deny in from 127.0.0.0/8
ufw deny in from ::1
ufw allow out on all
# Create valid rules for any authorized network connected sockets
ufw allow proto tcp from any to any port 22

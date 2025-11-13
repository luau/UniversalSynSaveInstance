sudo apt update
sudo apt install -y curl
sudo apt install -y openssl

curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh

sudo mv lit /usr/local/bin/
sudo mv luvi /usr/local/bin/
sudo mv luvit /usr/local/bin/

lit install
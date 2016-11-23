# ConfigurationVMS

## Use it!
This script has been tested on a Xubuntu 16.04 virtual machine running on VirtualBox.

In order to use it, please, run the following command:

```bash
sudo apt-get update && \
sudo apt-get install -y dos2unix wget && \
wget https://raw.githubusercontent.com/AgoraUS-G1-1617/Deliberations-ConfigurationVMS/master/script.sh && \
dos2unix script.sh && \
sudo bash script.sh | tee log.txt && \
rm script.sh
```

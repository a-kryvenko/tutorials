# Server configuration for web applications

General instruction for preparing server for hosting web applications.
This instruction is applicable for mostly all kind of web applications, except really complex apps, which require a lot of DevOps configuration.  
First of all, you need a VPS or VDS with installed Ubuntu, root user and ssh keys authorization configured.

Steps:

1.  Connect to server as root user via ssh
    ```shell
    ssh root@your_server_ip
    ```
2.  Add non root user for you website
    ```shell
    adduser www
    ```
3.  Add sudo privileges for you user
    ```shell
    usermod -aG sudo www
    ```
4. Disable password confirmation for sudo
    ```shell
    visudo
    ```
    and in the end of file add line
    ```bash
    www ALL=(ALL) NOPASSWD:ALL
    ```
5.  Allow SSH access in UFW (Uncomplicated firewall), and ports for http
    ```shell
    ufw allow OpenSSH
    ufw allow 80/tcp
    ufw allow 443/tcp
    ```
6.  Enable UFW
    ```shell
    ufw enable
    ```
7. Install and configure fail2ban
    ```shell
    apt install fail2ban
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    nano /etc/fail2ban/jail.d/sshd.local
    ```
    and add next configuration
    ```bash
    [sshd]
    enabled = true
    port = ssh
    filter = sshd
    logpath = /var/log/auth.log
    maxretry = 3
    bantime = 1h
    ```
    and now enable fail2ban
    ```shell
    systemctl start fail2ban
    systemctl enable fail2ban
    fail2ban-client status
    ```
8.  Copy you auth key information to new user
    ```shell
    rsync --archive --chown=www:www ~/.ssh /home/www
    ```
9.  Connect to server via you new user
    ```shell
    ssh www@your_server_ip
    ```
10.  Update packages information
    ```shell
    sudo apt update
    ```
11.  Install Docker
    ```shell
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    ```
    
    ```shell
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    ```
    
    ```shell
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    ```
    
    ```shell
    sudo apt update
    ```
    
    ```shell
    apt-cache policy docker-ce
    ```
    
    ```shell
    sudo apt install docker-ce
    ```
    
    ```shell
    sudo usermod -aG docker ${USER}
    ```
    
    ```shell
    su - ${USER}
    ```

    after this commands you will need to reconnect to server (to apply new group docker for you current user);

12.  Install docker-compose

    ```shell
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    ```
    
    ```shell
    sudo chmod +x /usr/local/bin/docker-compose
    ```

Optional You can create aliases for docker run and docker-compose run

1.  Edit file ~/.bashrc
    ```shell
    vi ~/.bashrc
    ```

2.  Insert at and of the file next aliases:
    ```shell
    alias dr='docker run --rm'
    alias dcr='docker-compose run --rm'
    ```
    
3.  Now instead long commands you can use simple:
    ```shell
    dcr php test.php
    ```

After all this actions you will have ready to use server for web applications and can install required web environment,
for example [docker-webserver](https://github.com/a-kryvenko/docker-webserver "Docker webserver repository") or [laravel webserver](https://github.com/a-kryvenko/laravel-10-webserver "Laravel webserver").

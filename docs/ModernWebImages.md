# Images in modern formats for WEB applications

Mostly all visitors (~96%) support modern images formats (webp, avif), usage of which allow to decrease transferred data size and increase page loading speed.

We can return images in these formats for visitors, who support them, on webserver level without web application changes. We need to create copy of our images in modern formats and configure NGINX to return copies instead of original images.

To do it we need do next steps:

1.  Install on our webserver **webp** and **imagemagic** packages:

    ```shell
    sudo apt-get install webp
    sudo apt install imagemagick
    ```

2.  Add variables definition to NGINX global configuration BEFORE “Server” block
    ```text
    map $http_accept $webp_suffix {
        default "";
        "~*webp" ".webp";
    }
    map $http_accept $avif_suffix {
        default "";
        "~*avif" ".avif";
    }
    ```

3.  Add config to NGINX website configuration INSIDE “Server” block

    ```text
    location ~* ^(/upload/.+)\.(png|jpe?g)$ {
        add_header Vary Accept;
        try_files $uri$avif_suffix $uri$webp_suffix $uri =404;
    }
    ```

    “/upload/” is path where contains you website images. This is relative path from webserver root folder.

    Probably you will need to change this path to you own, or add multiple locations

4.  Create folder for converter script, clone repository and set execution permissions
    ```shell
    mkdir /var/www/converter
    cd /var/www/converter
    git clone https://github.com/a-kryvenko/modern-web-images.git .
    chmod +x /var/www/converter/images-converter.sh
    ```

5.  Schedule script execution in crontab
    ```text
    00 02 * * * /var/www/converter/images-converter.sh /var/www/upload/
    ```
    
    where “/var/www/upload/” is path to you images directory

6.  Optional. You may want to run script at first time immediately
    ```shell
    /var/www/converter/images-converter.sh /var/www/upload/
    ```

As result, you will have copy of each image in modern formats:

```text
images/image1.jpeg
images/image1.jpeg.avif
images/image1.jpeg.webp
images/subfolder1/subfolder2/image2.png
images/subfolder1/subfolder2/image2.png.avif
images/subfolder1/subfolder2/image2.png.webp
```

and NGINX, based on visitor device, will return to him image in avif ,webp formats, on in original jpeg/png, if visitor don’t support modern formats.
# Menggunakan base image Ubuntu
FROM ubuntu:latest

# Instalasi dependencies dasar
RUN apt-get update && apt-get install -y curl sudo git unzip

# Salin start.sh ke container
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Jalankan script start.sh
CMD ["/start.sh"]

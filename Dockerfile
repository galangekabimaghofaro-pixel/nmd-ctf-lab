FROM ubuntu:22.04

# Hindari interaktif prompt saat instalasi
ENV DEBIAN_FRONTEND=noninteractive

# Install Node.js, OpenSSH server, dan utilitas dasar
RUN apt-get update && apt-get install -y \
    curl \
    openssh-server \
    sudo \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Buat direktori yang dibutuhkan oleh SSH
RUN mkdir /var/run/sshd

# Buat user 'analyst' dan set password 'blue_team_rocks'
RUN useradd -ms /bin/bash analyst && echo "analyst:blue_team_rocks" | chpasswd

# Konfigurasi port SSH ke 2275
RUN echo "Port 2275" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

WORKDIR /app
COPY . .
RUN npm install

# Expose port web dan SSH
EXPOSE 3075 2275

# Jalankan SSH server di background dan jalankan aplikasi Node.js
CMD ["sh", "-c", "/usr/sbin/sshd && npm start"]

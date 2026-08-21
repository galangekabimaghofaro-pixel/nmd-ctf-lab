FROM node:18-alpine

# Install OpenSSH server dan utilitas dasar
RUN apk update && apk add --no-cache openssh bash

# Buat user 'analyst' untuk Blue Team SSH, set password 'blue_team_rocks'
RUN adduser -D analyst && echo "analyst:blue_team_rocks" | chpasswd

# Konfigurasi SSH server agar mengizinkan akses
RUN mkdir /var/run/sshd
# Izinkan root/password login jika diperlukan untuk testing
RUN sed -i 's/#PermissiveRootLogin/PermissiveRootLogin/' /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Set working directory aplikasi web Anda
WORKDIR /app
COPY . .
RUN npm install

# Expose port web dan port SSH
EXPOSE 3075 2275

# Jalankan SSH server di background lalu jalankan aplikasi Node.js Anda
CMD ["sh", "-c", "echo 'Starting SSH server...'; /usr/sbin/sshd -D & npm start"]

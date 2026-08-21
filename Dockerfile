FROM node:18-alpine

# Install OpenSSH server, bash, dan utilitas penting
RUN apk update && apk add --no-cache openssh bash

# Buat user 'analyst' untuk Blue Team SSH, set password 'blue_team_rocks'
RUN adduser -D analyst && echo "analyst:blue_team_rocks" | chpasswd

# Wajib: Generate SSH host keys agar sshd mau berjalan di Alpine
RUN ssh-keygen -A

# Konfigurasi SSH agar mengizinkan password login
RUN sed -i 's/#PermissiveRootLogin/PermissiveRootLogin/' /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "Port 2275" >> /etc/ssh/sshd_config

# Set working directory aplikasi web Anda
WORKDIR /app
COPY . .
RUN npm install

# Expose port web dan port SSH
EXPOSE 3075 2275

# Jalankan SSH server pada port 2275 di background, lalu jalankan aplikasi Node.js
CMD ["sh", "-c", "/usr/sbin/sshd -p 2275 && npm start"]

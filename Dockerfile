FROM archlinux:latest

# Setuo mirror
RUN echo 'Server = http://mirrors.cat.net/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
RUN pacman -Sy --noconfirm
RUN pacman-key --init
RUN pacman -S archlinux-keyring --noconfirm
RUN pacman -Su --noconfirm
RUN pacman -S --noconfirm reflector
RUN reflector --protocol https -c Japan --sort rate --save /etc/pacman.d/mirrorlist
RUN pacman -Sy --noconfirm devtools base-devel --needed
RUN systemd-machine-id-setup

# Setup environment
ENV ALTER_MAIN_DIR="/home/user/main" ALTER_OUT_DIR="/home/user/repo" ALTER_WORK_DIR="/home/user/work"
RUN useradd -m -s /bin/bash -d "/home/user/" user
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/alter-repo"
WORKDIR /home/user/main/
COPY . /home/user/main/

# Run
ENTRYPOINT []
CMD ["sudo", "-E" ,"-u", "user" , "/home/user/main/scripts/docker.sh","user" , "--" , "/home/user/main/scripts/main.sh", "--user", "user"]

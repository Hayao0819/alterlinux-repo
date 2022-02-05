FROM archlinux:latest

# Setuo mirror
RUN echo 'Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
RUN pacman -Sy --noconfirm reflector
RUN reflector --protocol https -c Japan --sort rate --save /etc/pacman.d/mirrorlist
RUN pacman -Sy --noconfirm devtools base-devel
RUN systemd-machine-id-setup

# Setup environment
ENV ALTER_MAIN_DIR="/home/user/main" ALTER_OUT_DIR="/home/user/repo" ALTER_WORK_DIR="/home/user/out"
RUN useradd -m -s /bin/bash -d "/home/user/" user
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/alter-repo"
WORKDIR /home/user/main/
COPY . /home/user/main/

# Run
ENTRYPOINT []
CMD ["sudo", "-u", "user" , "/home/user/main/scripts/docker.sh","user" , "--" , "/home/user/main/scripts/main.sh", "--user", "user"]

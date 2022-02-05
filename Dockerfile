FROM archlinux:latest

# Setuo mirror
RUN echo 'Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
RUN pacman -Sy --noconfirm reflector
RUN reflector --protocol https -c Japan --sort rate --save /etc/pacman.d/mirrorlist
RUN pacman -Sy --noconfirm devtools base-devel
RUN systemd-machine-id-setup

# Setup environment
WORKDIR /Main
COPY . /Main
ENV ALTER_MAIN_DIR="/Main" ALTER_OUT_DIR="/Repo" ALTER_WORK_DIR="/Main/work"
RUN useradd -m -g root -s /bin/bash -d "/Main" user
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/alter-repo"

# Run
ENTRYPOINT []
CMD ["/Main/scripts/main.sh", "--user", "user"]

FROM archlinux:latest

# Setuo mirror
RUN echo 'Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
RUN pacman -Sy --noconfirm reflector
RUN reflector --protocol https -c Japan --sort rate --save /etc/pacman.d/mirrorlist

#Setup environment
ENV ALTER_WORK_DIR="/Main" ALTER_OUT_DIR="/Repo"

WORKDIR /Main
ENTRYPOINT []
CMD ["/Main/scripts/main.sh"]

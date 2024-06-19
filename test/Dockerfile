# https://nix.dev/manual/nix/2.22/installation/installing-docker.html
FROM docker.io/library/ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

RUN  printf %s\\n 'tzdata tzdata/Areas select Etc' 'tzdata tzdata/Zones/Etc select UTC' | debconf-set-selections \
  && apt update \
  && apt -y install nix-bin sudo \
&& echo >/dev/null

ARG  user=user
ARG group=user
ARG   uid=1000
ARG   gid=1000

RUN  userdel "$( id -un "${uid}" )" \
  && groupadd -g "${gid}" "${group}" \
  && useradd -u "${uid}" -g "${gid}" -G nix-users -G sudo -s /bin/bash --create-home "${user}" \
  && printf %s\\n "${user} ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers \
  && mkdir -p "/nix/store" \
  && chown --recursive "${user}:${gid}" "/nix" \
&& echo >/dev/null

USER ${user}

ENV USER="${user}"
# Should update <nixpkgs> before <home-manager> to make sure the versions match
RUN  nix-channel --add https://nixos.org/channels/nixos-24.05 nixpkgs \
  && nix-channel --update \
  && nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager \
  && nix-channel --update \
&& echo >/dev/null

RUN  nix-shell '<home-manager>' -A install

RUN  nix-env -iA nixpkgs.vim nixpkgs.git \
&& echo >/dev/null

ARG nix_bin=/home/${user}/.nix-profile/bin
RUN  printf %s\\n ". /home/${user}/.nix-profile/etc/profile.d/hm-session-vars.sh" >>"/home/${user}/.bashrc" \
  && printf %s\\n "PATH=$PATH:\"${nix_bin}\"" >>"/home/${user}/.bashrc" \
&& echo >/dev/null

WORKDIR "/home/${user}"

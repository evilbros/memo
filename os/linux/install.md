## remove snap

```
sudo snap remove --purge firefox
sudo snap remove --purge snap-store
sudo snap remove --purge gnome-3-38-2004

sudo snap remove --purge gtk-common-themes
sudo snap remove --purge snapd-desktop-integration
sudo snap remove --purge bare
sudo snap remove --purge core20
sudo snap remove --purge snapd

sudo apt remove --autoremove snapd


rm -rf ~/snap
sudo rm -rf /snap
sudo rm -rf /var/snap
sudo rm -rf /var/lib/snapd
sudo rm -rf /var/cache/snapd
```

## disable snap from installing

in folder /etc/apt/preferences.d, create file `nosnap` with contents

```
Package: snapd
Pin: release a=*
Pin-Priority: -10


Package: *
Pin: release a=mozilla
Pin-Priority: 999
```

## keep linux kernels

```
apt-mark hold linux-image-$(uname -r) linux-headers-$(uname -r)
```

## disable auto upgrade

- disable auto upgrade in apt.conf.d
- remove unattended-upgrades service


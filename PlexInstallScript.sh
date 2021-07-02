#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

sed -i 's/#arm_freq=800/over_voltage=6\narm_freq=2000\ngpu_freq=700/' /boot/config.txt

cat >> /boot/config.txt << EOF

gpu_mem=512
EOF

sed -i 's/#type=local/xserver-command=X -s 0 dpms/' /etc/lightdm/lightdm.conf

apt-get install -y autoconf automake libtool libharfbuzz-dev libfreetype6-dev libfontconfig1-dev libx11-dev libxrandr-dev libvdpau-dev libva-dev mesa-common-dev libegl1-mesa-dev yasm libasound2-dev libpulse-dev libuchardet-dev zlib1g-dev libfribidi-dev git libgnutls28-dev libgl1-mesa-dev libsdl2-dev cmake python3 python python-minimal git mpv libmpv-dev

cd /home/pi
wget https://github.com/koendv/qt5-opengl-raspberrypi/releases/download/v5.12.5-1/qt5-opengl-dev_5.12.5_armhf.deb
apt-get install -y ./qt5-opengl-dev_5.12.5_armhf.deb
rm qt5-opengl-dev_5.12.5_armhf.deb
mkdir /home/pi/pmp
cd /home/pi/pmp
git clone git://github.com/plexinc/plex-media-player
cd plex-media-player/
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Debug -DQTROOT=/usr/lib/qt5.12/ -DCMAKE_INSTALL_PREFIX=/usr/local/ ..
make -j4
make install

touch /home/pi/plex_startup.sh
cat > /home/pi/plex_startup.sh << EOF
plexmediaplayer
shutdown -h now
EOF
chmod 755 /home/pi/plex_startup.sh

mkdir /home/pi/.config/autostart
touch /home/pi/.config/autostart/plex.desktop
cat > /home/pi/.config/autostart/plex.desktop << EOF
plexmediaplayer
shutdown -h now
EOF

reboot

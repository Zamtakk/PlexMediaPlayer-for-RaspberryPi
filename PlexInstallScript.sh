#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Applying overclock"
sed -i 's/#arm_freq=800/over_voltage=6\narm_freq=2000\ngpu_freq=700/' /boot/config.txt

echo "Increasing GPU memory"
cat >> /boot/config.txt << EOF

gpu_mem=512
EOF

echo "Disabling screen timeout"
sed -i 's/#type=local/xserver-command=X -s 0 dpms/' /etc/lightdm/lightdm.conf

echo "Installing needed dependencies"
apt-get install -y autoconf automake libtool libharfbuzz-dev libfreetype6-dev libfontconfig1-dev libx11-dev libxrandr-dev libvdpau-dev libva-dev mesa-common-dev libegl1-mesa-dev yasm libasound2-dev libpulse-dev libuchardet-dev zlib1g-dev libfribidi-dev git libgnutls28-dev libgl1-mesa-dev libsdl2-dev cmake python3 python python-minimal git mpv libmpv-dev

echo "Downloading QT for Plex"
runuser -l pi -c 'wget https://github.com/koendv/qt5-opengl-raspberrypi/releases/download/v5.12.5-1/qt5-opengl-dev_5.12.5_armhf.deb -P /home/pi'

echo "Installing QT for Plex"
apt-get install -y /home/pi/qt5-opengl-dev_5.12.5_armhf.deb

echo "Removing Qt installer"
runuser -l pi -c 'rm qt5-opengl-dev_5.12.5_armhf.deb'

echo "Cloning Plex"
runuser -l pi -c 'mkdir /home/pi/pmp'
runuser -l pi -c 'git clone git://github.com/plexinc/plex-media-player /home/pi/pmp/plex-media-player'

echo "Building Plex"
runuser -l pi -c 'mkdir /home/pi/pmp/plex-media-player/build'
runuser -l pi -c 'cmake -DCMAKE_BUILD_TYPE=Debug -DQTROOT=/usr/lib/qt5.12/ -DCMAKE_INSTALL_PREFIX=/usr/local/ -B/home/pi/pmp/plex-media-player/build -S/home/pi/pmp/plex-media-player'
runuser -l pi -c 'make -j4 -C /home/pi/pmp/plex-media-player/build'

echo "Installing Plex"
make install -C /home/pi/pmp/plex-media-player/build

echo "Creating automatic startup for Plex"
runuser -l pi -c 'touch /home/pi/plex_startup.sh'
cat > /home/pi/plex_startup.sh << EOF
plexmediaplayer
shutdown -h now
EOF
chmod 755 /home/pi/plex_startup.sh

runuser -l pi -c 'mkdir /home/pi/.config/autostart'
runuser -l pi -c 'touch /home/pi/.config/autostart/plex.desktop'
cat > /home/pi/.config/autostart/plex.desktop << EOF
plexmediaplayer
shutdown -h now
EOF

echo "Done"
echo "Please reboot the Pi..."

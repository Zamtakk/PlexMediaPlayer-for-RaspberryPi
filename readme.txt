Information:
i:      as prefix is information about the task or command that follows
-       as prefix is something you need to do
>       as prefix is a command you need to execute on the Pi
>>>>    starts a block of text that you need to paste in the file you just opened or created
<<<<    Ends the block of text that needs to be copied
IF:     Only perform the actions below the IF: that are indented with a <TAB> when the statement next to the IF: resolves to 'true'
<TAB>   If something is tabbed (indented), it belongs to the IF: statement above the tabbed lines and should only be performed if the IF: is true

++++++++++++++++++++++++++ Preparing the Raspberry Pi ++++++++++++++++++++++++++
i: First we need to get a few items
- Grab a Raspberry Pi 4 (2GB or higher)
- A heatsink for the Raspberry Pi and a stand that can hold the Pi vertically. Or special case that can propperly cool the Pi.
- Grab a charger for the Pi (5V 2A or more with USB-C cable)
- Grab an mirco SD card of sufficiant speed (Ex. SanDisk Ultra 16GB A1)
- Grab a keyboard
- Optionally grab a mouse.
- Grab a monitor or tv
- Micro HDMI to HDMI (or displayport, depending on the monitor you use)
- Grab a USB mirco SD card reader (Or a mirco SD to SD adapter and SD card reader for your pc)
- If you can, use an ethernet cable. Otherwise WiFi should work as well.

i: First we need to install the Raspberry Pi imager tool on the host computer
IF: Used host is Windows
    - Download and install the tool from (https://www.raspberrypi.org/software/)
IF: Used host is Ubuntu
    - Open a terminal and run
    > sudo snap install rpi-imager

i: Now we will use the tool to install the RPi OS onto the micro SD card that will be used in the RPi
- Insert SD card in computer (USB SD reader can be used)
- Run imager
- Click 'Choose OS' > Select Raspberry Pi OS 32-bit (Recommended)
- Select SD Card
- Click write

i: The SD card is now ready!
- Remove the SD card from the computer and put it in the Raspberry Pi.
- Connect the monitor, keyboard, (mouse) and ethernet to the Pi.
i: Before powering on the Pi, make sure you have applied a headsink and a stand or some other proper cooling sollution.
i: I used 4 10x10x10mm Aluminum Heat Sinks from Aliexpress placed in a 2x2 config on the ARM chip of the pi and a piece of wood with a slit to hold the pi vertically.
- Power on the Pi with the charger.

++++++++++++++++++++++++++ Configuring the Raspberry Pi ++++++++++++++++++++++++++
i: Now we have to do a few basic configuration steps.
- After the Pi is fully booted, click next on the 'Welcome to Raspberry Pi' wizard.
- Set your Country, Language and Timezone. Optionally use the checkbox below to override your language with english. And click next.
- Optionally change the default password (which is 'raspberry'). Proceed with next.
- Check the box if your screen shows a black border on the edges, and click next.
- If you use an ethernet cable, you can click 'skip' in the WiFi section. Otherwise select your wifi SSID and insert the password. Continue with next.
- Click next to start updating the software. And wait until it is complete.
- Click restart to apply the new software changes.

i: Time for some optimizations.
- Open a terminal with 'Ctrl + Alt + T'
i: We will now open the Raspberry Pi config to change the GPU memory
> sudo raspi-config
- Navigate to [Performance options] > [GPU Memory]
- Insert '512' into the input field. NOTE: the numlock will probably be off, check that first.
- Click [OK]
- Click [Finish]
- Click [Yes] to reboot now

i: Now we will overclock the Raspberry
- Open a terminal with 'Ctrl + Alt + T'
i: In the config file we will add our overclock settings
> sudo nano /boot/config.txt
- In the section that says: "#uncomment to overclock the arm. 700 MHz is the default." add the following lines:
>>>>
over_voltage=6
arm_freq=2000
gpu_freq=700
<<<<
- Save the file with 'Ctrl + O' and exit nano with 'Ctrl + X'
i: Now we need to reboot.
> sudo reboot

i: When the device is booted, check that the overclock works.
- Open a terminal with 'Ctrl + Alt + T'
i: We will watch the clock speed to verify
> watch -n 1 vcgencmd measure_clock arm
i: The clockspeed with probably hover around 600,000,000
- Open a browser window and check if the clockspeed spikes up to 2,000,000,000
- Close the watch command with 'Ctrl + C'

i: Now we need to disable screen timeout because Plex will not be detected and the screen will sleep while watching
> sudo nano /etc/lightdm/lightdm.conf
- Under the line that states '[Seat:*]' add the following:
>>>>
xserver-command=X -s 0 dpms
<<<<
- Save the file with 'Ctrl + O' and exit nano with 'Ctrl + X'

++++++++++++++++++++++++++ Build and install Plex ++++++++++++++++++++++++++
i: Now it is time to install Plex, for this we need a lot of dependencies because we will build Plex from source code.
i: You might want to open these instructions on the Pi in the browser. Copy the command and paste it in the terminal with middle click on the mouse.

> sudo apt-get install -y autoconf automake libtool libharfbuzz-dev libfreetype6-dev libfontconfig1-dev libx11-dev libxrandr-dev libvdpau-dev libva-dev mesa-common-dev libegl1-mesa-dev yasm libasound2-dev libpulse-dev libuchardet-dev zlib1g-dev libfribidi-dev git libgnutls28-dev libgl1-mesa-dev libsdl2-dev cmake python3 python python-minimal git mpv libmpv-dev

i: Now we download and install Qt for running plex
> cd /home/pi
> wget https://github.com/koendv/qt5-opengl-raspberrypi/releases/download/v5.12.5-1/qt5-opengl-dev_5.12.5_armhf.deb
> sudo apt-get install -y ./qt5-opengl-dev_5.12.5_armhf.deb
> rm qt5-opengl-dev_5.12.5_armhf.deb

i: Now we download and build Plex
> mkdir /home/pi/pmp
> cd /home/pi/pmp
> git clone git://github.com/plexinc/plex-media-player
> cd plex-media-player/
> mkdir build
> cd build
> cmake -DCMAKE_BUILD_TYPE=Debug -DQTROOT=/usr/lib/qt5.12/ -DCMAKE_INSTALL_PREFIX=/usr/local/ ..
> make -j4
> sudo make install

i: Now we need to add an autostart entry to automatically start plex and shutdown when plex closes.
> cd /home/pi
> nano plex_startup.sh
>>>>
plexmediaplayer
shutdown -h now
<<<<
> sudo chmod 755 ./plex_startup.sh

> mkdir /home/pi/.config/autostart
> nano /home/pi/.config/autostart/plex.desktop
>>>>
[Desktop Entry]
Type=Application
Name=Plex
Exec=/home/pi/plex_startup.sh
<<<<

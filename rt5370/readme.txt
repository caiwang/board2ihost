=================
firmware
=================
1, rt2870.bin.029源自raspberry pi系统中的 /lib/firmware/rt2870.bin
2, rt2870.bin.033源自rt5370.tar.bz2中的common目录
   rt5370.tar.bz2源自
   http://www.mediatek.com/en/downloads/rt8070-rt3070-rt3370-rt3572-rt5370-rt5372-rt5572-usb-usb/ 

3, 应用： cp rt2870.bin.029 /lib/firmware/rt2870.bin


=================
driver, 应用于 kernel 3.0.36+
radxa_rock_pro_lite_ubuntu_14.04_server_141030_sdcard.zip SD image
=================
cp  ins_rt2x00.sh  /root/
cp  -r  rt2x00.k3036  /root/
echo "@reboot sudo bash /root/ins_rt2x00.sh &" >> /var/spool/cron/crontabs/root

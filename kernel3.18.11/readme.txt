1, radxa�ṩ�������ļ�������kernel3.18.11��rock lite�ϱ���
rockchip_defconfig.lite
rk3188-radxarock-lite-k31811.dts 

#����rock pro����
rockchip_defconfig.pro
rk3188-radxarock-pro.dts


2, ���rock lite
cp  rockchip_defconfig.lite  path-to-kernel-source/arch/arm/configs/rockchip_defconfig
cp  rk3188-radxarock-lite-k31811.dts  path-to-kernel-source/arch/arm/boot/dts/rk3188-radxarock.dts

make rockchip_defconfig  (���� .config) 


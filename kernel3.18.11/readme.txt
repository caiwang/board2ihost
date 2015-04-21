1, radxa提供的配置文件，用于kernel3.18.11在rock lite上编译
rockchip_defconfig.lite
rk3188-radxarock-lite-k31811.dts 

#用于rock pro编译
rockchip_defconfig.pro
rk3188-radxarock-pro.dts


2, 针对rock lite
cp  rockchip_defconfig.lite  path-to-kernel-source/arch/arm/configs/rockchip_defconfig
cp  rk3188-radxarock-lite-k31811.dts  path-to-kernel-source/arch/arm/boot/dts/rk3188-radxarock.dts

make rockchip_defconfig  (生成 .config) 


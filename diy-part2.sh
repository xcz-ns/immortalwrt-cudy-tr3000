#!/bin/bash

# 下载第三方软件包
git clone --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/openwrt-passwall-packages
git clone --depth 1 https://github.com/gdy666/luci-app-lucky.git package/lucky
git clone --depth 1 https://github.com/papagaye744/luci-theme-design package/luci-theme-design
git clone --depth 1 https://github.com/xuanranran/luci-app-design-config package/luci-app-design-config
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth 1 https://github.com/vernesong/OpenClash.git package/openclash && mv package/openclash/luci-app-openclash package/ && rm -rf package/openclash package/luci-app-openclash/root/{etc/openclash/GeoSite.dat,usr/share/openclash/ui/{zashboard,metacubexd}}

# 删除冲突软件
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-design

# 自定义内容
ZZZ="package/emortal/default-settings/files/99-default-settings"
cat >> "$ZZZ" <<EOF
uci set system.@system[0].hostname='CudyTR3000'
uci set luci.main.mediaurlbase=/luci-static/argon
uci set network.lan.ipaddr='192.168.10.1'
uci commit
sed -i "s#^root:[^:]*:#root:\$5\$7ceNgrs8ZgrGVxv8\$UFWOtsaXR3KC2k0PeXFff.z47etH3dJZcpBv9zDpE08:#" /etc/shadow
EOF
sed -i '/exit 0/d' "$ZZZ"
echo "exit 0" >> "$ZZZ"

# 下载并配置 lucky 二进制文件
BASE="https://release.66666.host"
DIR="files/usr/bin"
ARCH="arm64"
mkdir -p "$DIR"
echo "[1/2] 正在解析最新版本信息..."
VER=$(curl -sL "$BASE/" | grep -o 'href="\./v[^/]*' | cut -d/ -f2 | sort -rV | head -1)
[ -z "$VER" ] && { echo "❌ 获取版本失败"; exit 1; }
SUB=$(curl -sL "$BASE/$VER/" | grep -o 'href="\./[^/]*' | cut -d/ -f2 | grep -i '^[0-9].*lucky' | head -1)
[ -z "$SUB" ] && { echo "❌ 未找到 lucky 子目录"; exit 1; }
PKG=$(curl -sL "$BASE/$VER/$SUB/" | grep -o 'href="[^"]*' | cut -d'"' -f2 | grep -i "Linux.*$ARCH.*\.tar\.gz" | head -1)
[ -z "$PKG" ] && { echo "❌ 未找到 $ARCH 包"; exit 1; }
echo "✅ 成功匹配: $VER / $PKG"
echo "[2/2] 开始下载并提取二进制..."
curl -sL --connect-timeout 10 "$BASE/$VER/$SUB/$PKG" | tar -xz -C "$DIR" lucky || { echo "❌ 下载或解压失败"; exit 1; }
echo "🎉 完成：已成功提取到 $DIR/lucky"
ls -lh "$DIR/lucky"

# 自定义插件内容
touch ./.config
cat >> .config <<EOF
CONFIG_TARGET_ROOTFS_TARGZ=y
CONFIG_TARGET_ROOTFS_EXT4FS=y
# --- Web 界面与美化 ---
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-theme-design=y
CONFIG_PACKAGE_luci-app-argon-config=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-lucky=y
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-wireguard=y
CONFIG_PACKAGE_luci-app-uhttpd=y
CONFIG_PACKAGE_luci-app-upnp=y

# 关闭 passwall
CONFIG_PACKAGE_luci-app-passwall=n
CONFIG_PACKAGE_luci-app-passwall_Iptables_Transparent_Proxy=n
CONFIG_PACKAGE_luci-app-passwall_Nftables_Transparent_Proxy=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Haproxy=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Hysteria=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Kcptun=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_NaiveProxy=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_PDNSD=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Libev_Client=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Libev_Server=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Rust_Client=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Rust_Server=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_Libev_Client=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_Libev_Server=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Simple_Obfs=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_SingBox=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_GO=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_Plus=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray_Geodata=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray_Plugin=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Xray=n
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Xray_Plugin=n
CONFIG_PACKAGE_xray-core=n
CONFIG_PACKAGE_sing-box=n
CONFIG_PACKAGE_v2ray-core=n
CONFIG_PACKAGE_v2ray-geodata=n
CONFIG_PACKAGE_shadowsocks-rust=n
CONFIG_PACKAGE_shadowsocksr-libev=n
CONFIG_PACKAGE_hysteria=n
CONFIG_PACKAGE_naiveproxy=n
CONFIG_PACKAGE_haproxy=n
CONFIG_PACKAGE_chinadns-ng=n
CONFIG_PACKAGE_simple-obfs=n
CONFIG_PACKAGE_tuic-client=n
CONFIG_PACKAGE_geoview=n
CONFIG_PACKAGE_trojan-plus=n
CONFIG_PACKAGE_trojan-go=n
CONFIG_PACKAGE_brook=n
CONFIG_PACKAGE_kcptun=n
EOF
sed -i 's/^[ \t]*//g' ./.config
# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

XORG_DRI=dri
inherit linux-info xorg-2

DESCRIPTION="X.Org driver for Intel cards"

#KEYWORDS="~amd64 ~ia64 ~x86 ~amd64-fbsd -x86-fbsd"
IUSE="+sna +udev uxa dri1 dri2 dri3"

REQUIRED_USE="|| ( sna uxa )
		dri? ( || ( dri1 dri2 dri3 ) )
"

RDEPEND="x11-libs/libXext
	x11-libs/libXfixes
	>=x11-libs/pixman-0.27.1
	>=x11-libs/libdrm-2.4.29[video_cards_intel]
	sna? (
		>=x11-base/xorg-server-1.10
	)
	udev? (
		virtual/udev
	)
"
DEPEND="${RDEPEND}
	x11-base/xorg-proto"

src_configure() {
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable dri)
		$(use_enable dri1)
		$(use_enable dri2)
		$(use_enable dri3)
		$(use_enable sna)
		$(use_enable uxa)
		$(use_enable udev)
		--disable-xvmc
	)
	use dri3 && XORG_CONFIGURE_OPTIONS+=(
		--with-default-dri=3
	)
	xorg-2_src_configure
}

pkg_postinst() {
	if linux_config_exists \
		&& ! linux_chkconfig_present DRM_I915_KMS; then
		echo
		ewarn "This driver requires KMS support in your kernel"
		ewarn "  Device Drivers --->"
		ewarn "    Graphics support --->"
		ewarn "      Direct Rendering Manager (XFree86 4.1.0 and higher DRI support)  --->"
		ewarn "      <*>   Intel 830M, 845G, 852GM, 855GM, 865G (i915 driver)  --->"
		ewarn "	      i915 driver"
		ewarn "      [*]       Enable modesetting on intel by default"
		echo
	fi
}

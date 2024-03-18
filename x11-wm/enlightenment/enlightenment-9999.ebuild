# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

inherit meson
[ "${PV}" = 9999 ] && inherit git-r3

DESCRIPTION="Enlightenment window manager"
HOMEPAGE="http://www.enlightenment.org/"
EGIT_REPO_URI="https://git.enlightenment.org/core/${PN}.git"
[ "${PV}" = 9999 ] || SRC_URI="http://download.enlightenment.org/rel/apps/${PN}/${P/_/-}.tar.xz"

LICENSE="BSD-2"
[ "${PV}" = 9999 ] || KEYWORDS="~amd64 ~x86"
SLOT="0.17/0.21"

E_MODULES_DEFAULT=(
	conf-applications conf-bindings conf-dialogs conf-display conf-interaction
	conf-intl conf-menus conf-paths conf-performance conf-randr conf-shelves
	conf-theme conf-window-manipulation conf-window-remembers

	appmenu backlight battery bluez4 clock connman contact cpufreq everything
	fileman fileman-opinfo gadman ibar ibox lokker mixer msgbus music-control
	notification pager pager16 quickaccess shot start syscon systray tasks
	teamwork temperature tiling winlist wizard xkbswitch
)
E_MODULES=(
	packagekit wl-desktop-shell wl-drm wl-fb wl-x11 wl-wl wl-text-input
)
IUSE_E_MODULES=(
	"${E_MODULES_DEFAULT[@]/#/+enlightenment_modules_}"
	"${E_MODULES[@]/#/enlightenment_modules_}"
)
IUSE="doc +eeze egl nls pam pm-utils static-libs systemd ukit wayland ${IUSE_E_MODULES[@]}"

RDEPEND="
	>=dev-libs/efl-1.10.0[X,wayland?]
	>=media-libs/elementary-1.10.0
	virtual/udev
	x11-libs/libxcb
	x11-libs/xcb-util-keysyms
	enlightenment_modules_mixer? ( >=media-libs/alsa-lib-1.0.8 )
	nls? ( sys-devel/gettext )
	pam? ( sys-libs/pam )
	pm-utils? ( sys-power/pm-utils )
	systemd? ( sys-apps/systemd )
	wayland? (
		>=dev-libs/wayland-1.3.0
		>=x11-libs/pixman-0.31.1
		>=x11-libs/libxkbcommon-0.3.1
	)"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

S="${WORKDIR}/${P/_/-}"

src_configure() {
	local emesonargs=(
		-Dsimple-x11=false
		-Dconf=true
		-Ddevice-udev=true # instead of hal
		-Dfiles=true
		-Dinstall-enlightenment-menu=true
		-Dinstall-sysactions=true

		-Ddoc=$(usex doc true false)
		-Dwayland-egl=$(usex egl true false)
		-Dnls=$(usex nls true false)
		-Dpam=$(usex pam true false)
		-Dstatic=$(usex static-libs true false)
		-Dsystemd=$(usex systemd true false)
		-Dmount-udisks=$(usex ukit true false)
		-Dmount-eeze=$(usex eeze true false)
	)

	if use wayland; then
		emesonargs+=(	-Dwl-drm=true
				-Dwayland=true
				-Dxwayland=true
				-Dwl-desktop-shell=true
		) 
	fi

	local i
	for i in ${E_MODULES_DEFAULT[@]} ${E_MODULES[@]}; do
		emesonargs+=( -D${i}=$(usex enlightenment_modules_${i} true false))
	done

	meson_src_configure
}

src_install() {
	default
	meson_src_install
	prune_libtool_files
}

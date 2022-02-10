# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="wlroots"
HOMEPAGE="https://gitlab.freedesktop.org/wlroots/wlroots.git"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://gitlab.freedesktop.org/wlroots/wlroots.git"
	inherit git-r3
	SLOT="0/9999"
else
	SRC_URI="https://gitlab.freedesktop.org/${PN}/${PN}/-/releases/${PV}/downloads/${P}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64 ~ppc64 ~x86"
	SLOT="0/14"
fi

LICENSE="MIT"
IUSE="x11-backend X vulkan"

DEPEND="
	>=dev-libs/libinput-1.14.0:0=
	>=dev-libs/wayland-1.19.0
	>=dev-libs/wayland-protocols-1.17.0
	gui-libs/egl-wayland
	media-libs/mesa[gles2,vulkan?]
	sys-auth/seatd:=
	virtual/libudev
	x11-libs/libdrm
	x11-libs/libxkbcommon
	x11-libs/pixman
	x11-backend? ( x11-libs/libxcb:0= )
	X? (
		x11-base/xwayland
		x11-libs/libxcb:0=
		x11-libs/xcb-util-image
		x11-libs/xcb-util-wm
	)
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	>=dev-libs/wayland-protocols-1.17
	>=dev-util/meson-0.58.1
	virtual/pkgconfig
"

src_configure() {
	local wl_backends="drm,libinput$(use x11-backend && echo ,x11)"

	# xcb-util-errors is not on Gentoo Repository (and upstream seems inactive?)
	local emesonargs=(
		"-Dxcb-errors=disabled"
		"-Dexamples=false"
		"-Dwerror=false"
		"-Drenderers=gles2$(use vulkan && echo ,vulkan)"
		-Dxwayland=$(usex X enabled disabled)
		-Dbackends="${wl_backends}"
	)

	meson_src_configure
}

pkg_postinst() {
	elog "You must be in the input group to allow your compositor"
	elog "to access input devices via libinput."
}

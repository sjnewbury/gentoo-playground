# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{9,10,11,12} )

inherit meson python-any-r1

MY_PN=${PN/sway-}

DESCRIPTION="A fork of Chromium's wayland proxy to allow HiDPI X11 clients in swaywm"
HOMEPAGE="https://github.com/akvadrako/sommelier"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/akvadrako/${MY_PN^}.git"
else
	SRC_URI="https://github.com/akvadrako/${MYPN^}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

PATCHES=(
	"${FILESDIR}/display-socket.patch"
	"${FILESDIR}/drm-device.patch"
)

BDEPEND="
	>=app-text/scdoc-1.9.2
	virtual/pkgconfig
	"
DEPEND="
	dev-libs/wayland
	dev-libs/wayland-protocols
	media-libs/mesa[gbm]
	x11-libs/pixman
	x11-libs/libxcb
	"
RDEPEND="${DEPEND}"

src_configure() {
	emesonargs=(
		-Dxwayland_path="Xwayland"
		-Dxwayland_gl_driver_path=""
		-Dxwayland_shm_driver="dmabuf"
		-Dshm_driver="dmabuf"
		-Dvirtwl_device="/dev/null"
		-Ddrm_device="/dev/dri/renderD128"
	)
	meson_src_configure
}

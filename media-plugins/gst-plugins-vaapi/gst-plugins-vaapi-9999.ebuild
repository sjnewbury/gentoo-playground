# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI=git://gitorious.org/vaapi/gstreamer-vaapi.git
EGIT_BOOTSTRAP="echo 'EXTRA_DIST =' > gtk-doc.make; eautoreconf"

inherit autotools autotools-utils git-2

MY_PN="gstreamer-vaapi"
DESCRIPTION="GStreamer VA-API plugins"
HOMEPAGE="http://www.splitted-desktop.com/~gbeauchesne/gstreamer-vaapi/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs opengl X drm wayland"

DEPEND="dev-libs/glib:2
	opengl? ( virtual/opengl )
	X? ( x11-libs/libX11 )
	drm? ( x11-libs/libdrm )
	wayland? ( dev-libs/wayland )
	>=media-libs/gstreamer-1.0.0
	>=media-libs/gst-plugins-base-1.0.0
	x11-libs/libva
	>=virtual/ffmpeg-0.6[vaapi]"

RDEPEND="${DEPEND}"

DOCS=(AUTHORS README NEWS)

S="${WORKDIR}/${MY_PN}-${PV}"

EGIT_HAS_SUBMODULES=1

src_configure() {
	local myeconfargs=(
		$(use_enable opengl glx)
		$(use_enable X x11) 
		$(use_enable drm) 
		$(use_enable wayland) 
		--with-gstreamer-api=1.2
	)
	autotools-utils_src_configure
}

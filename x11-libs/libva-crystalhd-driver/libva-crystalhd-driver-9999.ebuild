# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libva-crystalhd-driver/libva-crystalhd-driver-9999.ebuild,v 1.1 2012/11/21 17:53:31 aballier Exp $

EAPI=4

SCM=""
if [ "${PV%9999}" != "${PV}" ] ; then # Live ebuild
	SCM=git-2
	EGIT_BRANCH=master
	EGIT_REPO_URI="git://gitorious.org/crystalhd-video/crystalhd-video.git"
fi

inherit eutils autotools ${SCM}

DESCRIPTION="CrystalHD backend for VA-API (libva)"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/vaapi"
if [ "${PV%9999}" != "${PV}" ] ; then # Live ebuild
	SRC_URI=""
	S="${WORKDIR}/${PN}"
else
	SRC_URI="http://www.freedesktop.org/software/vaapi/releases/libva-crystalhd-driver/${P}.tar.bz2"
fi

LICENSE="GPL-2"
SLOT="0"
if [ "${PV%9999}" = "${PV}" ] ; then
	KEYWORDS="~amd64 ~x86"
else
	KEYWORDS=""
fi
IUSE="debug opengl"

RDEPEND=">=x11-libs/libva-1.1.0[X,opengl?]
	opengl? ( virtual/opengl )
	x11-libs/libcrystalhd
	!x11-libs/crystalhd-video"

DEPEND="${DEPEND}
	virtual/pkgconfig"

src_prepare() {
	epatch ${FILESDIR}/${P}-api-0.32.patch
	epatch ${FILESDIR}/${P}-api-0.34.patch

	# VA Buffer types dropped upstream
	sed -i \
		-e '/VAEncH264VUIBufferType/d' \
		-e '/VAEncH264SEIBufferType/d' \
		 src/debug.h || die
	# Rename to libva-crystalhd-driver
	sed -i \
		-e 's/crystalhd-video/libva-crystalhd-driver/g' \
		-e 's/crystalhd_video/libva_crystalhd_driver/g' \
		configure.ac || die
	eautoreconf
}

src_configure() {
	econf \
		--disable-silent-rules \
		$(use_enable debug) \
		$(use_enable opengl glx)
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc NEWS README AUTHORS
	find "${D}" -name '*.la' -delete
}

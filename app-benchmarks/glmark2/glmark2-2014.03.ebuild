# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit waf-utils

DESCRIPTION="Opengl test suite"
HOMEPAGE="https://launchpad.net/glmark2"
SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="X wayland gles2"

REQUIRED_USE="X ( !wayland )"

RDEPEND="media-libs/libpng
	media-libs/mesa[gles2?,wayland?]
	X? ( x11-libs/libX11 )
"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
"

src_prepare() {
	rm -rf ${S}/src/libpng
	sed -i -e 's#libpng12#libpng#g' ${S}/wscript ${S}/src/wscript_build || die
}

append_flavor() {
	FLAVORS="$([[ -n ${FLAVORS} ]] && echo ${FLAVORS},)${1}"
}

src_configure() {
	: ${WAF_BINARY:="${S}/waf"}

	local myconf
	local FLAVORS
	
	if use X; then
		use gles2 && append_flavor x11-glesv2
		append_flavor x11-gl
	fi
	if use wayland; then
		use gles2 && append_flavor wayland-glesv2
		append_flavor wayland-gl
	fi

	# it does not know --libdir specification, dandy huh
	CCFLAGS="${CFLAGS}" LINKFLAGS="${LDFLAGS}" "${WAF_BINARY}" \
		--prefix=/usr \
		--with-flavors=${FLAVORS} \
		${myconf} \
		configure || die "configure failed"
}

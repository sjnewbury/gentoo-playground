# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=8

PYTHON_COMPAT=( python3_{9,10,11,12,10} )
PYTHON_REQ_USE='threads(+)'

inherit python-single-r1 waf-utils

DESCRIPTION="Opengl test suite"
HOMEPAGE="https://github.com/${PN}"

if [[ ${PV} == 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN}/${PN}.git"
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/refs/tags/${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="X wayland gles2"

REQUIRED_USE="X? ( !wayland )"

RDEPEND="media-libs/libpng
	media-libs/mesa[gles2?,wayland?]
	X? ( x11-libs/libX11 )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_prepare() {
	default
	rm -rf ${S}/src/libpng
	sed -i -e 's#libpng12#libpng#g' ${S}/wscript ${S}/src/wscript_build || die
}

append_flavor() {
	FLAVORS="$([[ -n ${FLAVORS} ]] && echo ${FLAVORS},)${1}"
}

src_configure() {
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
	waf-utils_src_configure \
		--with-flavors=${FLAVORS} \
		${myconf} 
}

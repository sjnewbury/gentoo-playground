# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xcb-proto/xcb-proto-1.10.ebuild,v 1.14 2014/07/04 13:20:35 haubi Exp $

EAPI=5

PYTHON_COMPAT=( python{2_7,3_3,3_4} )
XORG_MULTILIB=yes

inherit python-r1 xorg-2

DESCRIPTION="X C-language Bindings protocol headers"
HOMEPAGE="http://xcb.freedesktop.org/"
EGIT_REPO_URI="git://anongit.freedesktop.org/git/xcb/proto"
[[ ${PV} != 9999* ]] && \
	SRC_URI="http://xcb.freedesktop.org/dist/${P}.tar.bz2"

#KEYWORDS=""
IUSE=""

RDEPEND="${PYTHON_DEPS}"
DEPEND="${RDEPEND}
	dev-libs/libxml2"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_configure() {
	python_export_best
	xorg-2_src_configure
}

multilib_src_configure() {
	autotools-utils_src_configure

	if multilib_is_native_abi; then
		python_parallel_foreach_impl autotools-utils_src_configure
	fi
}

multilib_src_compile() {
	default

	if multilib_is_native_abi; then
		python_foreach_impl autotools-utils_src_compile -C xcbgen \
			top_builddir="${BUILD_DIR}"
	fi
}

src_install() {
	xorg-2_src_install

	# pkg-config file hardcodes python sitedir, bug 486512
	sed -i -e '/pythondir/s:=.*$:=/dev/null:' \
		"${ED}"/usr/lib*/pkgconfig/xcb-proto.pc || die
}

multilib_src_install() {
	default

	if multilib_is_native_abi; then
		python_foreach_impl autotools-utils_src_install -C xcbgen \
			top_builddir="${BUILD_DIR}"
	fi
}

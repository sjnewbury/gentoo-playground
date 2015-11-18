# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libxcb/libxcb-1.10.ebuild,v 1.15 2014/08/21 02:28:34 floppym Exp $

EAPI=5

PYTHON_COMPAT=( python{2_7,3_3,3_4} )
PYTHON_REQ_USE=xml

XORG_DOC=doc
XORG_MULTILIB=yes
inherit python-any-r1 xorg-2

DESCRIPTION="X C-language Bindings library"
HOMEPAGE="http://xcb.freedesktop.org/"
EGIT_REPO_URI="git://anongit.freedesktop.org/git/xcb/libxcb"
[[ ${PV} != 9999* ]] && \
	SRC_URI="http://xcb.freedesktop.org/dist/${P}.tar.bz2"

#KEYWORDS=""
IUSE="doc selinux test xkb"

RDEPEND=">=dev-libs/libpthread-stubs-0.3-r1[${MULTILIB_USEDEP}]
	>=x11-libs/libXau-1.0.7-r1[${MULTILIB_USEDEP}]
	>=x11-libs/libXdmcp-1.1.1-r1[${MULTILIB_USEDEP}]"
# Note: ${PYTHON_USEDEP} needs to go verbatim
DEPEND="${RDEPEND}
	test? ( dev-libs/check[${MULTILIB_USEDEP}] )
	doc? ( app-doc/doxygen[dot] )
	dev-libs/libxslt
	${PYTHON_DEPS}
	$(python_gen_any_dep \
		">=x11-proto/xcb-proto-1.11[${MULTILIB_USEDEP},\${PYTHON_USEDEP}]")"

python_check_deps() {
	has_version --host-root ">=x11-proto/xcb-proto-1.10[${MULTILIB_USEDEP},${PYTHON_USEDEP}]"
}

pkg_setup() {
	python-any-r1_pkg_setup
}

src_configure() {
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable doc build-docs)
		$(use_enable selinux)
		$(use_enable xkb)
		--enable-xinput
	)
	xorg-2_src_configure
}

# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

if [[ ${PV} = 9999* ]]; then
	EGIT_REPO_URI="git://anongit.freedesktop.org/git/wayland/${PN}"
	GIT_ECLASS="git-r3"
	EXPERIMENTAL="true"
	AUTOTOOLS_AUTORECONF=1
fi

inherit autotools-multilib toolchain-funcs $GIT_ECLASS

DESCRIPTION="Wayland libinput library"
HOMEPAGE="http://libinput.freedesktop.org/"

if [[ $PV = 9999* ]]; then
	SRC_URI="${SRC_PATCHES}"
else
	SRC_URI="http://www.freedesktop.org/software/${PN}/${P}.tar.xz"
fi

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="static-libs"

RDEPEND="dev-libs/expat[${MULTILIB_USEDEP}]
	virtual/libffi[${MULTILIB_USEDEP}]
	>=dev-libs/libevdev-0.4[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_configure() {
	local myeconfargs=(
		$(use_enable static-libs static)
	)
	autotools-multilib_src_configure
}

src_test() {
	export XDG_RUNTIME_DIR="${T}/runtime-dir"
	mkdir "${XDG_RUNTIME_DIR}" || die
	chmod 0700 "${XDG_RUNTIME_DIR}" || die

	autotools-multilib_src_test
}

# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

if [[ ${PV} = 9999* ]]; then
	EGIT_REPO_URI="git://anongit.freedesktop.org/git/wayland/${PN}"
	GIT_ECLASS="git-r3"
	EXPERIMENTAL="true"
	AUTOTOOLS_AUTORECONF=1
fi
inherit eutils autotools-multilib udev $GIT_ECLASS

DESCRIPTION="Library to handle input devices in Wayland"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/libinput/"
if [[ $PV = 9999* ]]; then
	SRC_URI="${SRC_PATCHES}"
else
	SRC_URI="http://www.freedesktop.org/software/${PN}/${P}.tar.xz"
fi


LICENSE="MIT"
SLOT="0/10"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="test"
# Tests require write access to udev rules directory which is a no-no for live system.
# Other tests are just about logs, exported symbols and autotest of the test library.
RESTRICT="test"

RDEPEND="
	>=dev-libs/libevdev-0.4
	>=sys-libs/mtdev-1.1
	virtual/libudev
"
DEPEND="${RDEPEND}
	virtual/pkgconfig"
#	test? (
#		>=dev-libs/check-0.9.10
#		dev-util/valgrind
#		sys-libs/libunwind )

#src_prepare() {
#	# Doc handling in kinda strange but everything
#	# is available in the tarball already.
#	sed -e 's/^\(SUBDIRS =.*\)doc\(.*\)$/\1\2/' \
#		-i Makefile.am Makefile.in || die
#}

src_configure() {
	# gui can be built but will not be installed
	# building documentation silently fails with graphviz syntax errors
	local myeconfargs=(
		--disable-event-gui
		$(use_enable test tests)
		--with-udev-dir="$(get_udevdir)"
	)
# 		--disable-documentation
	autotools-multilib_src_configure
}

multilib_src_install() {
	default
	multilib_is_native_abi && dodoc -r doc/html
}

multilib_src_install_all() {
	prune_libtool_files
}

src_test() {
	export XDG_RUNTIME_DIR="${T}/runtime-dir"
	mkdir "${XDG_RUNTIME_DIR}" || die
	chmod 0700 "${XDG_RUNTIME_DIR}" || die

	autotools-multilib_src_test
}

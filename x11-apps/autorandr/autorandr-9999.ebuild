# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )

inherit systemd toolchain-funcs python-single-r1

DESCRIPTION="Auto-detect the connected display hardware and load the
appropriate X11 setup using xrandr"

if [[ ${PV} == 9999* ]]; then
	EGIT_REPO_URI=https://github.com/phillipberndt/${PN}
	inherit git-r3
	SLOT=0/9999
else
	SRC_URI="https://github.com/phillipberndt/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
	SLOT=0
fi
IUSE=""

RDEPEND="
	x11-apps/xrandr
	${PYTHON_DEPS}"

DEPEND="${RDEPEND}"

src_compile() {
	default

	cd contrib/autorandr_launcher
	$(tc-getCC) ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} ${LIBS} -o autorandr_launcher autorandr_launcher.c -lxcb -lxcb-randr || die building autorandr_launcher
}

src_install() {
	default

	exeinto /usr/libexec
	doexe contrib/autorandr_launcher/autorandr_launcher
	systemd_douserunit ${FILESDIR}/autorandr-launcher.service
}

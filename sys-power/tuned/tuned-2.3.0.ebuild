# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} )
inherit python-single-r1 systemd

DESCRIPTION="A tool that performs monitoring and adaptive configuration of the system according to selected profile."
HOMEPAGE="https://fedorahosted.org/tuned"
SRC_URI="https://fedorahosted.org/releases/${PN:0:1}/${PN:1:1}/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"

DEPEND="sys-apps/sed"
RDEPEND="sys-apps/systemd
		dev-python/decorator[${PYTHON_USEDEP}]
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
		dev-python/pyudev[${PYTHON_USEDEP}]
		dev-python/configobj[${PYTHON_USEDEP}]
		sys-apps/ethtool
		sys-apps/gawk
		=sys-power/powertop-2.5*"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
# Needs more work
#	epatch "${FILESDIR}/${P}-python3.patch"
	python_fix_shebang .

	sed -i	\
		-e "/^VERSION/s: =.*: = ${P}:" \
		-e "/^RELEASE/s: =.*: = gentoo:" \
		-e "/^UNITDIR/s: =.*: = $(systemd_get_unitdir):" \
		-e "/^PYTHON_SITELIB/s: =.*: = $(python_get_sitedir):" \
		-e "/\/run/d" \
		Makefile || die "sed failed"
}

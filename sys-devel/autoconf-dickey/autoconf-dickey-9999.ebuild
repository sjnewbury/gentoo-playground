# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://salsa.debian.org/joachim-guest/autoconf-dickey"
	inherit git-r3
else
	MY_PV=${PV/_p/+}
	SRC_URI="https://salsa.debian.org/joachim-guest/${PN}/-/archive/debian/${MY_PV}/${PN}-debian-${MY_PV}.tar.bz2"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-linux"
fi

inherit toolchain-autoconf

DESCRIPTION="Used to create autoconfiguration files"
HOMEPAGE="http://invisible-island.net/autoconf/"

LICENSE="GPL-3"
SLOT="${PV}"
IUSE="emacs"

DEPEND=">=sys-devel/m4-1.4.16
	>=dev-lang/perl-5.6"
RDEPEND="${DEPEND}
	!~sys-devel/${P}:2.5
	>=sys-devel/autoconf-wrapper-13"
[[ ${PV} == "9999" ]] && DEPEND+=" >=sys-apps/texinfo-4.3"
PDEPEND="emacs? ( app-emacs/autoconf-mode )"

src_configure() {
	econf --program-suffix=-dickey \
	                     --datadir=/usr/share/autoconf-dickey

}

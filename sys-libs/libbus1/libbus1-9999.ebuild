# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools multilib-minimal git-r3

DESCRIPTION="A new kernel-based message bus system"
HOMEPAGE="https://github.com/bus1/"

if [[ ${PV} == 9999* ]]; then
	EGIT_REPO_URI=https://github.com/bus1/libbus1.git
	SRC_URI=""
else
	die "No releases yet!"
fi

LICENSE="|| ( LGPL-2.1 )"
SLOT="0"

if [[ ${PV} == 9999* ]]; then
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
fi

IUSE=""

ECONF_SOURCE="${S}"

src_prepare() {
	mkdir -p build/m4
	default
	eautoreconf
}

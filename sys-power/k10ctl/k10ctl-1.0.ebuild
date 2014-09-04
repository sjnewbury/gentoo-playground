# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-power/cpupower/cpupower-3.13.ebuild,v 1.2 2014/02/18 07:33:27 ssuominen Exp $

EAPI=5

DESCRIPTION="AMD Family 10h (aka K10) P-State, frequency and voltage modification utility"
HOMEPAGE="http://sourceforge.net/projects/k10ctl"
SRC_URI="mirror://sourceforge/k10ctl/k10ctl.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

S="${WORKDIR}/${PN}"

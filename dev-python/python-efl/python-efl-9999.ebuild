# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id: dev-python/python-efl/python-efl-1.12.0.ebuild,v 1.2 2015/06/08 Exp $

EAPI=7
PYTHON_COMPAT=( python3_{9,10,11,12} )

case "${PV}" in
	(9999*)
	KEYWORDS=""
	VCS_ECLASS=git-r3
	EGIT_REPO_URI="https://git.enlightenment.org/bindings/python/${PN}.git"
	EGIT_PROJECT="${PN}.git"
	case "${PV}" in
		(*.9999*) EGIT_BRANCH="${PN}-${PV:0:4}";;
	esac
	AUTOTOOLS_AUTORECONF=1
	;;
	(*)
	KEYWORDS="~amd64 ~arm ~x86"
	SRC_URI="https://download.enlightenment.org/rel/bindings/python/${P/_/-}.tar.bz2"
	;;
esac
inherit distutils-r1 ${VCS_ECLASS}

DESCRIPTION="Python bindings for the EFL"
HOMEPAGE="http://enlightenement.org"

LICENSE="GPL-3 LGPL-3"
SLOT="0/${PV:0:4}"
IUSE="doc ${PYTHON_USEDEP}"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND=">=dev-libs/efl-${PV:0:4}
	>=dev-python/cython-0.19.1[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	virtual/pkgconfig
	${PTHON_DEPS}"

DOCS=( AUTHORS ChangeLog README )

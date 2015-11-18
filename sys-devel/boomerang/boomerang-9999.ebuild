# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/boomerang/boomerang-9999.ebuild,v 1.5 2014/07/26 09:08:29 ssuominen Exp $

EAPI=5

ESVN_REPO_URI="svn://svn.code.sf.net/p/boomerang/code/trunk"
#ESVN_PROJECT="boomerang"

if [[ ${PV} = 9999* ]]; then
	SVN_ECLASS="subversion"
fi

inherit cmake-utils ${SVN_ECLASS}

DESCRIPTION="Boomerang decompiler"
HOMEPAGE="http://boomerang.sourceforge.net/"

if [[ $PV = 9999* ]]; then
	KEYWORDS=""
fi

LICENSE="BSD-2"
SLOT="0"
#IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

CMAKE_IN_SOURCE_BUILD=1
CMAKE_USE_DIR="${WORKDIR}/${P}/${PN}"

src_unpack() {
	default
	[[ $PV = 9999* ]] && subversion_src_unpack
}

src_prepare() {
	subversion_src_prepare
	epatch "${FILESDIR}"/fix-install.patch
	cmake-utils_src_prepare
}

src_configure() {
#	local mycmakeargs=(
#	)

	cmake-utils_src_configure
}

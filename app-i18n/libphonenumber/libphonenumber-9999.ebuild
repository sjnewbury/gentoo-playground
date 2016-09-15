# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="Google's common Java, C++ and JavaScript library for parsing, formatting, and validating international phone numbers."
HOMEPAGE="https://github.com/googlei18n/libphonenumber"
SRC_URI=""

EGIT_REPO_URI="https://github.com/googlei18n/libphonenumber.git"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS=""

RDEPEND=""

DEPEND="${RDEPEND}
	dev-cpp/gtest
	dev-libs/protobuf
	deb-libs/boost[threads]
	virtual/pkgconfig"

S=${WORKDIR}/${P}/cpp

src_prepare() {
	# Debian patches
	pushd ..
	epatch "${FILESDIR}"/0001-Boost-build-fix.patch
	epatch "${FILESDIR}"/0002-C-symbols-map.patch
	epatch "${FILESDIR}"/0003-maven-exclude-demo.patch
	epatch "${FILESDIR}"/0006-main-lib-jdk5.patch
#	epatch "${FILESDIR}"/0008-tools-jdk5.patch
#	epatch "${FILESDIR}"/0009-maven-tests-forkmode.patch
	epatch "${FILESDIR}"/0010-reproducible-build.patch
#	epatch "${FILESDIR}"/gcc-6-ftbfs.patch
	epatch "${FILESDIR}"/readdir_r-is-deprecated.patch
	popd

	default
}

#src_configure() {
#	local mycmakeargs=(
#		USE_BOOST=OFF
#	)
# 	cmake-utils_src_configure
#}

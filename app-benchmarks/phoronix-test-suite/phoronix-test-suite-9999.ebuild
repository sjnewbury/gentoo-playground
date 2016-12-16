# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# TODO:
# * add installation of new documenation (README.html and documentation/) as real dodoc,
#   currently docs end inside the normal install path (/usr/share/phoronix-test-suite/documentation/)

# Ebuild was taken from #216656

EAPI=6
inherit eutils git-r3

EGIT_REPO_URI="https://github.com/phoronix-test-suite/phoronix-test-suite.git"
#default:
#EGIT_BRANCH="master"

DESCRIPTION="Comprehensive testing and benchmarking platform"
HOMEPAGE="http://phoronix-test-suite.com"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="get-all-deps"

RDEPEND="dev-lang/php[cli,gd,pcntl]
	sys-process/time
	sys-apps/lsb-release
	get-all-deps? ( app-shells/tcsh
		dev-lang/perl
		dev-libs/libaio
		dev-util/ftjam
		dev-vcs/git
		dev-util/scons
		media-libs/glew
		media-libs/freeimage
		media-libs/imlib2
		media-libs/jpeg
		>=media-libs/libpng-1.2
		>=media-libs/libsdl-1.2
		media-libs/openal
		media-libs/portaudio
		>=media-libs/sdl-image-1.2
		>=media-libs/sdl-net-1.2
		media-libs/libvorbis
		sys-devel/bison
		sys-devel/flex
		sys-devel/gcc[fortran]
		amd64? ( sys-devel/gcc[multilib] )
		sys-libs/zlib
		media-libs/freeglut
		>=virtual/jre-1.5
		=virtual/libstdc++-3.3
		x11-base/xorg-server
		>=x11-libs/gtk+-2
		x11-libs/libXvMC
		x11-libs/libXv
		dev-qt/qtcore:4 )"

src_unpack() {
	git-r3_src_unpack
	cd "${S}"
	
	sed -i -e "s,export PTS_DIR=\`pwd\`,export PTS_DIR=\"/usr/share/${PN}\"," ${PN}
}

src_install() {
	dodir /usr/share/${PN}
	insinto /usr/share/${PN}
	exeinto /usr/bin
	doins -r "${S}"/{documentation,pts-core,README.md} || die "Install failed!"
	fperms a+x /usr/share/${PN}/pts-core/external-test-dependencies/scripts/*.sh
	fperms a+x /usr/share/${PN}/pts-core/hooks/startup/template.sh
	doexe phoronix-test-suite || die "Installing the executable failed!"
}

pkg_postinst() {
	if ! use get-all-deps ; then
		elog "For several tests external dependencies are needed. You can"
		elog "easily install them with setting the useflag 'get-all-deps'."
		elog "When not having the deps installed, the testsuite will ask for"
		elog "the root password when installing tests that require external"
		elog "dependencies and install them systemwide via portage."
		elog "These are the possible deps:"
		elog "app-shells/tcsh"
		elog "dev-lang/perl"
		elog "dev-libs/libaio"
		elog "dev-util/ftjam"
		elog "dev-util/git"
		elog "dev-util/scons"
		elog "media-libs/glew"
		elog "media-libs/freeimage, due to problems with this package you will have to get the ebuild from bugreport #213969 and manually unmask the build"
		elog "media-libs/imlib2"
		elog "media-libs/jpeg"
		elog ">=media-libs/libpng-1.2"
		elog ">=media-libs/libsdl-1.2"
		elog "media-libs/openal"
		elog "media-libs/portaudio"
		elog ">=media-libs/sdl-image-1.2"
		elog ">=media-libs/sdl-net-1.2"
		elog "media-libs/libvorbis"
		elog "sys-devel/bison"
		elog "sys-devel/flex"
		if use amd64 ; then
			elog "sys-devel/gcc with fortran and multilib useflag active"
		else
			elog "sys-devel/gcc with fortran useflag active"
		fi
		elog "media-libs/freeglut"
		elog ">=virtual/jre-1.5"
		elog "=virtual/libstdc++-3.3"
		elog "x11-base/xorg-server"
		elog ">=x11-libs/gtk+-2"
		elog "x11-libs/libXvMC"
		elog "x11-libs/libXv"
	fi
}

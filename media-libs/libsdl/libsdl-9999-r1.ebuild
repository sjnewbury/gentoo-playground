# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit git-r3 cmake-multilib

DESCRIPTION="Simple Direct Media Layer (sdl-1.2 compatibility)"
HOMEPAGE="https://github.com/libsdl-org/sdl12-compat"

# Used for .pc and ./include/
# See https://github.com/libsdl-org/sdl12-compat/issues/34
#SRC_URI="https://libsdl.org/release/SDL-1.2.15.tar.gz"

EGIT_REPO_URI="https://github.com/libsdl-org/sdl12-compat"
LICENSE="ZLIB"
SLOT="0"

MULTILIB_WRAPPED_HEADERS=( /usr/include/SDL/SDL_config.h /usr/include/SDL/SDL_platform.h )

# Those are fakes and just there for compat with other ebuilds
IUSE="oss alsa nas X dga xv xinerama fbcon tslib aalib opengl libcaca +sound +video +joystick custom-cflags pulseaudio static-libs"

src_unpack() {
	default
	git-r3_src_unpack
}


src_prepare() {
	sed -i \
		-e 's;test_program(testsprite;#test_program(testsprite;' \
		CMakeLists.txt || die

	cmake_src_prepare
}

multilib_src_install() {
	cmake_src_install

	#dolib.so "${BUILD_DIR}"/libSDL-1.2.so*
	#dosym libSDL-1.2.so /usr/$(get_libdir)/libSDL.so

	mkdir -p "${ED}"/usr/$(get_libdir)/pkgconfig

	sed \
		-e "s;@prefix@;${EROOT}/usr;" \
		-e 's;@libdir@;${prefix}/'"$(get_libdir);" \
		"${FILESDIR}/sdl-config" > "${T}/sdl-config" || die
	dobin "${T}/sdl-config"

	sed \
		-e "s;@prefix@;${EROOT}/usr;" \
		-e 's;@libdir@;${prefix}/'"$(get_libdir);" \
		"${FILESDIR}/sdl.pc.in" > "${T}/sdl.pc" || die
	cp "${T}"/sdl.pc "${ED}"/usr/$(get_libdir)/pkgconfig/sdl.pc
}

# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit git-r3 cmake-multilib autotools

DESCRIPTION="Simple Direct Media Layer (sdl-1.2 compatibility)"
HOMEPAGE="https://github.com/libsdl-org/sdl12-compat"

# Used for .pc and ./include/
# See https://github.com/libsdl-org/sdl12-compat/issues/34
SRC_URI="https://libsdl.org/release/SDL-1.2.15.tar.gz"

EGIT_REPO_URI="https://github.com/libsdl-org/sdl12-compat"
LICENSE="ZLIB"
SLOT="0"

MULTILIB_WRAPPED_HEADERS=( /usr/include/SDL/SDL_config.h )

# Those are fakes and just there for compat with other ebuilds
IUSE="oss alsa nas X dga xv xinerama fbcon tslib aalib opengl libcaca +sound +video +joystick custom-cflags pulseaudio static-libs"

src_unpack() {
	default
	git-r3_src_unpack
}

libsdl_copy_src() {
	cp -a "${WORKDIR}/SDL-1.2.15" "${WORKDIR}/SDL-1.2.15_${ABI}"
}

src_prepare() {
	pushd ${WORKDIR}/SDL-1.2.15

	mv configure.in configure.ac || die

	# Save time by only creating what we need
	sed -i -e '/AC_OUTPUT/Q' configure.ac || die
	sed -i -e '/build-deps/d' Makefile.in || die
	sed -i -e '/pkgconfig/d' Makefile.in || die
	echo "AC_OUTPUT(Makefile sdl.pc)" >> configure.ac

	AT_M4DIR="${EPREFIX}/usr/share/aclocal acinclude" eautoreconf
	multilib_foreach_abi libsdl_copy_src

	popd

	sed -i \
		-e 's;test_program(testsprite;#test_program(testsprite;' \
		CMakeLists.txt || die

	cmake-utils_src_prepare
}

multilib_src_configure() {
	pushd ${WORKDIR}/SDL-1.2.15_${ABI}
	econf
	popd

	cmake-utils_src_configure
}

multilib_src_install() {
	pushd ${WORKDIR}/SDL-1.2.15_${ABI}
		emake DESTDIR="${D}" install-hdrs install-man install-data
	popd

	default

	dolib.so "${BUILD_DIR}"/libSDL-1.2.so*
	dosym libSDL-1.2.so /usr/$(get_libdir)/libSDL.so

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

# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/webkit-gtk/webkit-gtk-2.4.3.ebuild,v 1.2 2014/06/21 20:00:28 pacho Exp $

EAPI="5"
GCONF_DEBUG="no"
PYTHON_COMPAT=( python{2_6,2_7} )

inherit cmake-utils check-reqs eutils flag-o-matic pax-utils python-any-r1 toolchain-funcs versionator virtualx git-r3

#MY_P="webkitgtk-${PV}"
DESCRIPTION="Open source web browser engine"
HOMEPAGE="http://www.webkitgtk.org/"
#SRC_URI="http://www.webkitgtk.org/releases/${MY_P}.tar.xz"
EGIT_REPO_URI=git://git.webkit.org/WebKit.git
#EGIT_REPO_URI="https://github.com/WebKitForWayland/webkit.git"

LICENSE="LGPL-2+ BSD"
SLOT="4" # soname version of libwebkit2gtk-3.0
KEYWORDS=
IUSE="aqua debug +egl +geoloc gles2 +gstreamer +introspection +jit libsecret +opengl glx spell wayland +webgl +X ftl-jit indexeddb gtk2plugin inspector experimental"
# bugs 372493, 416331
REQUIRED_USE="
	geoloc? ( introspection )
	introspection? ( gstreamer )
	gles2? ( egl )
	webgl? ( ^^ ( gles2 opengl ) )
	!webgl? ( ?? ( gles2 opengl ) )
	|| ( aqua wayland X )
	ftl-jit? ( jit )
	introspection
"

# cmake build defaults to using introspection, just force useflag on for now
# use sqlite, svg by default
# Aqua support in gtk3 is untested
# gtk2 is needed for plugin process support
# gtk3-3.10 required for wayland
RDEPEND="
	dev-libs/libxml2:2
	dev-libs/libxslt
	media-libs/harfbuzz:=[icu(+)]
	media-libs/libwebp:=
	virtual/jpeg:0=
	>=media-libs/libpng-1.4:0=
	>=x11-libs/cairo-1.10:=[X]
	>=dev-libs/glib-2.36.0:2
	>=x11-libs/gtk+-3.6.0:3[aqua=,introspection?]
	>=dev-libs/icu-3.8.1-r1:=
	>=net-libs/libsoup-2.42.0:2.4[introspection?]
	dev-db/sqlite:3=
	>=x11-libs/pango-1.30.0.0
    X? ( x11-libs/libXrender x11-libs/libXt )
	gtk2plugin? ( >=x11-libs/gtk+-2.24.10:2 )

	egl? ( media-libs/mesa[egl] )
	geoloc? ( >=app-misc/geoclue-2.1.5:2.0 )
	gles2? ( media-libs/mesa[gles2] )
	gstreamer? (
		>=media-libs/gstreamer-1.2:1.0
		>=media-libs/gst-plugins-base-1.2:1.0 )
	introspection? ( >=dev-libs/gobject-introspection-1.32.0 )
	libsecret? ( app-crypt/libsecret )
	opengl? ( virtual/opengl )
	spell? ( >=app-text/enchant-0.22:= )
	wayland? ( >=x11-libs/gtk+-3.10:3[wayland] )
	webgl? (
		|| ( x11-libs/cairo[opengl] x11-libs/cairo[gles2] ) 
		X? ( x11-libs/libXcomposite x11-libs/libXdamage ) )
	ftl-jit? ( sys-devel/llvm sys-libs/libcxxabi )
"

# paxctl needed for bug #407085
# Need real bison, not yacc
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	dev-lang/perl
	|| (
		virtual/rubygems[ruby_targets_ruby20]
		virtual/rubygems[ruby_targets_ruby21]
		virtual/rubygems[ruby_targets_ruby19]
	)
	>=app-accessibility/at-spi2-core-2.5.3
	>=dev-libs/atk-2.8.0
	>=dev-util/gtk-doc-am-1.10
	dev-util/gperf
	>=sys-devel/bison-2.4.3
	>=sys-devel/flex-2.5.33
	|| ( >=sys-devel/gcc-4.7 >=sys-devel/clang-3.3 )
	sys-devel/gettext
	>=sys-devel/make-3.82-r4
	virtual/pkgconfig

	introspection? ( jit? ( sys-apps/paxctl ) )
	test? (
		dev-lang/python:2.7
		dev-python/pygobject:3[python_targets_python2_7]
		x11-themes/hicolor-icon-theme
		jit? ( sys-apps/paxctl ) )
"

#S="${WORKDIR}/${MY_P}"

CHECKREQS_DISK_BUILD="18G" # and even this might not be enough, bug #417307

pkg_pretend() {
	if [[ ${MERGE_TYPE} != "binary" ]] && is-flagq "-g*" && ! is-flagq "-g*0" ; then
		einfo "Checking for sufficient disk space to build ${PN} with debugging CFLAGS"
		check-reqs_pkg_pretend
	fi

	if ! test-flag-CXX -std=c++11; then
		die "You need at least GCC 4.7.x or Clang >= 3.3 for C++11-specific compiler flags"
	fi
}

pkg_setup() {
	# Check whether any of the debugging flags is enabled
	if [[ ${MERGE_TYPE} != "binary" ]] && is-flagq "-g*" && ! is-flagq "-g*0" ; then
		if is-flagq "-ggdb" && [[ ${WEBKIT_GTK_GGDB} != "yes" ]]; then
			replace-flags -ggdb -g
			ewarn "Replacing \"-ggdb\" with \"-g\" in your CFLAGS."
			ewarn "Building ${PN} with \"-ggdb\" produces binaries which are too"
			ewarn "large for current binutils releases (bug #432784) and has very"
			ewarn "high temporary build space and memory requirements."
			ewarn "If you really want to build ${PN} with \"-ggdb\", add"
			ewarn "WEBKIT_GTK_GGDB=yes"
			ewarn "to your make.conf file."
		fi
		einfo "You need to have at least 18GB of temporary build space available"
		einfo "to build ${PN} with debugging CFLAGS. Note that it might still"
		einfo "not be enough, as the total space requirements depend on the flags"
		einfo "(-ggdb vs -g1) and enabled features."
		check-reqs_pkg_setup
	fi

	[[ ${MERGE_TYPE} = "binary" ]] || python-any-r1_pkg_setup
}

src_prepare() {
    cmake-utils_src_prepare
#    epatch -p1 "${FILESDIR}"/wayland/*.patch
#    epatch "${FILESDIR}"/disable-gtk-glx.patch
}

src_configure() {
    local mycmakeargs="
		-DPORT=GTK
	";
    tc-export CC;

    # Silence developer warnings
    mycmakeargs+=" -Wno-dev"

    use jit || append-cppflags -DENABLE_JIT=0 -DENABLE_YARR_JIT=0 -DENABLE_ASSEMBLER=0;
    use alpha && append-ldflags "-Wl,--no-relax";
    use sparc && filter-flags "-mvis";
    use ppc64 && append-flags "-mminimal-toc";
    if ! use ia64; then
        append-ldflags "-Wl,--no-keep-memory";
    fi;
    # FIXME: WebKit is currently auto defaulting to gold so this fails atm
    #if ! $(tc-getLD) --version | grep -q "GNU gold"; then
    #    append-ldflags "-Wl,--reduce-memory-overheads";
    #fi;
    if has_version "virtual/rubygems[ruby_targets_ruby21]"; then
        export RUBY="$(type -P ruby21)";
    else
        if has_version "virtual/rubygems[ruby_targets_ruby20]"; then
            export RUBY="$(type -P ruby20)";
        else
            export RUBY="$(type -P ruby19)";
        fi;
    fi;


    if use experimental; then
        mycmakeargs+=" -DENABLE_CSP_NEXT=ON"
        if (use gles2 || use opengl); then
            mycmakeargs+=" -DENABLE_CSS_COMPOSITING=ON
                    -DENABLE_THREADED_COMPOSITOR=ON
		    -DENABLE_CSS_SHAPES=ON"
        fi
    fi

    [ "${PV}" == 9999 ] && mycmakeargs+=" -DDEVELOPER_MODE=ON"
    
    mycmakeargs+="
		$(cmake-utils_use_enable aqua QUARTZ_TARGET)
		$(cmake-utils_use debug DEBUG )
		$(cmake-utils_use_enable geoloc GEOLOCATION)
		$(cmake-utils_use_enable gstreamer VIDEO)
 		$(cmake-utils_use_enable gstreamer WEB_AUDIO)
 		$(cmake-utils_use_enable jit JIT)
 		$(cmake-utils_use_enable ftl-jit FTL_JIT)
 		$(cmake-utils_use_enable libsecret CREDENTIAL_STORAGE)
 		$(cmake-utils_use_enable spell SPELLCHECK)
 		$(cmake-utils_use_enable webgl WEBGL)
 		$(cmake-utils_use_enable wayland WAYLAND_TARGET)
 		$(cmake-utils_use_enable X X11_TARGET)
 		$(cmake-utils_use_enable indexeddb INDEXED_DATABASE)
 		$(cmake-utils_use gles2 WTF_USE_GLES2)
 		$(cmake-utils_use egl WTF_USE_EGL)
 		$(cmake-utils_use opengl WTF_USE_OPENGL)
 		$(cmake-utils_use glx WTF_USE_GLX)
 		$(cmake-utils_use_enable gtk2plugin PLUGIN_PROCESS_GTK2)
 		$(cmake-utils_use_enable inspector INSPECTOR)
		";
    cmake-utils_src_configure
}

src_compile() {
	# Try to avoid issues like bug #463960
	unset DISPLAY
	cmake-utils_src_compile
}

src_test() {
	# Tests expect an out-of-source build in WebKitBuild
	ln -s . WebKitBuild || die "ln failed"

	# Prevents test failures on PaX systems
	use jit && pax-mark m $(list-paxables Programs/*[Tt]ests/*) # Programs/unittests/.libs/test*

	unset DISPLAY
	# Tests need virtualx, bug #294691, bug #310695
	# Parallel tests sometimes fail
	Xemake -j1 check
}

src_install() {
	DOCS="ChangeLog" # other ChangeLog files handled by src_install

	# https://bugs.webkit.org/show_bug.cgi?id=129242
	MAKEOPTS="${MAKEOPTS} -j1" cmake-utils_src_install

	#newdoc Source/WebKit/gtk/ChangeLog ChangeLog.gtk
	#newdoc Source/JavaScriptCore/ChangeLog ChangeLog.JavaScriptCore
	#newdoc Source/WebCore/ChangeLog ChangeLog.WebCore

	# Prevents crashes on PaX systems
	use jit && pax-mark m "${ED}usr/bin/jsc-3"
}

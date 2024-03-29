EAPI=7

inherit autotools systemd flag-o-matic

if [[ ${PV} == 9999* ]]; then
	inherit git-r3
	#EGIT_REPO_URI=https://github.com/Aetf/kmscon.git
	EGIT_REPO_URI=https://github.com/AOSC-Dev/kmscon.git
	EGIT_REPO_BRANCH=fix
	KEYWORDS=
else
	SRC_URI="https://www.freedesktop.org/software/${PN}/releases/${P}.tar.xz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="KMS/DRM based virtual Console Emulator"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/kmscon"

LICENSE="MIT LGPL-2.1 BSD-2"
SLOT="0"
IUSE="debug doc +drm +fbdev +gles2 +optimizations +pango pixman static-libs systemd +unicode"

COMMON_DEPEND="
	>=virtual/udev-172
	x11-libs/libxkbcommon
	dev-libs/libtsm
	drm? ( x11-libs/libdrm
		>=media-libs/mesa-8.0.3 )
	gles2? ( >=media-libs/mesa-8.0.3[gles2] )
	systemd? ( sys-apps/systemd )
	pango? ( x11-libs/pango dev-libs/glib:2 )
	pixman? ( x11-libs/pixman )"
RDEPEND="${COMMON_DEPEND}
	x11-misc/xkeyboard-config"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	x11-base/xorg-proto
	doc? ( dev-util/gtk-doc )"

REQUIRED_USE="gles2? ( drm )"

# args - names of renderers to enable
renderers_enable() {
	if [[ "x${RENDER}" == "x" ]]; then
		RENDER="$1"
		shift
	else
		for i in $@; do
			RENDER+=",${i}"
		done
	fi
}

# args - names of font renderer backends to enable
fonts_enable() {
	if [[ "x${FONTS}" == "x" ]]; then
		FONTS="$1"
		shift
	else
		for i in $@; do
			FONTS+=",${i}"
		done
	fi
}

# args - names of video backends to enable
video_enable() {
	if [[ "x${VIDEO}" == "x" ]]; then
		VIDEO="$1"
		shift
	else
		for i in $@; do
			VIDEO+=",${i}"
		done
	fi
}

src_prepare() {
	eapply "${FILESDIR}"/0001-uterm-drm-ensure-EGL-config-matches-required-GBM-vis.patch
	eapply_user
	sed -i -e 's/\[libsystemd-daemon libsystemd-login\]/\[libsystemd\]/' configure.ac
	eautoreconf
}

src_configure() {
	# Video backends

	if use fbdev; then
		video_enable fbdev
	fi

	if use drm; then
		video_enable drm2d
	fi

	if use gles2; then
		video_enable drm3d
	fi

	# Font rendering backends

	if use unicode; then
		fonts_enable unifont
	fi

	if use pango; then
		fonts_enable pango
	fi

	# Console rendering backends

	renderers_enable bbulk

	if use gles2; then
		renderers_enable gltex
	fi

	if use pixman; then
		renderers_enable pixman
	fi

	# kmscon sets -ffast-math unconditionally
	strip-flags

	# xkbcommon not in portage
	econf \
		$(use_enable static-libs static) \
		$(use_enable debug) \
		$(use_enable optimizations) \
		$(use_enable systemd multi-seat) \
		--htmldir=/usr/share/doc/${PF}/html \
		--with-video=${VIDEO} \
		--with-fonts=${FONTS} \
		--with-renderers=${RENDER} \
		--with-sessions=dummy,terminal
}

src_install() {
	emake DESTDIR="${D}" install
	systemd_dounit "${S}/docs"/kmscon{,vt@}.service
}

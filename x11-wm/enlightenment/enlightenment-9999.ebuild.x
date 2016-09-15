# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

E_PKG_IUSE="doc nls"
EFL_USE_GIT="yes"
EFL_GIT_REPO_CATEGORY="core"
inherit eutils efl

DESCRIPTION="Enlightenment DR17 window manager"
HOMEPAGE="http://www.enlightenment.org/"

SLOT="0.17"

IUSE="eeze opengl pam pm-utils +sysactions systemd tracker
		+udev udisks wayland xinerama xscreensaver debug X"

IUSE_ENLIGHTENMENT_MODULES="
	+appmenu
	+backlight
	+battery
	+bluez4
	+clock
	+conf
	+connman
	+cpufreq
	everything
	+fileman
	+fileman_opinfo
	+gadman
	+ibar
	+ibox
	+mixer
	+msgbus
	+music-control
	+notification
	+pager
	+quickaccessD
	+shot
	+start
	+syscon
	+systray
	+tasks
	+temperature
	+tiling
	wl-desktop-shell
	+winlist
	+wizard
	xkbswitch

	+conf-applications
	+conf-dialogs
	+conf-display
	+conf-interaction
	+conf-intl
	+conf-menus
	+conf-paths
	+conf-performance
	conf-randr
	+conf-shelves
	+conf-theme
	+conf-window_manipulation
	+conf-window_remembers
"

RDEPEND="
	pam? ( sys-libs/pam )
	tracker? ( app-misc/tracker )
	pm-utils? ( sys-power/pm-utils )
	>=dev-libs/efl-9999[opengl?]

	eeze? ( >=dev-libs/efl-9999[mount] )

	X? ( || ( >=dev-libs/efl-9999[X] >=dev-libs/efl-9999[xcb] ) )
	>=media-libs/elementary-9999
	udev? ( virtual/udev )
	systemd? ( sys-apps/systemd )
	wayland? ( dev-libs/efl[wayland?,drm]
		>=dev-libs/wayland-1.2.0
		>=x11-libs/pixman-0.31.1
		>=x11-libs/libxkbcommon-0.3.1 )
	enlightenment_modules_mixer? ( media-libs/alsa-lib )
	enlightenment_modules_everything? ( app-text/aspell sys-devel/bc )

	debug? ( sys-devel/gdb )
"

REQUIRED_USE="
    enlightenment_modules_wl-desktop-shell? ( wayland )
    enlightenment_modules_xkbswitch? ( X )
    enlightenment_modules_everything? ( X )
    enlightenment_modules_conf-randr? ( X )
    enlightenment_modules_shot? ( X )
    "

DEPEND="${RDEPEND}"

expand_iuse() {
	local flags="$1" prefix="$2" requirement="$3"

	local fullname= flag= is_default=""
	local has_requirement=false

	[[ -z "${requirement}" ]] || has_requirement=true

	for flag in ${flags}; do
		[[ "${flag#+}" == "${flag}" ]] && is_default="" || is_default="+"

		fullname="${prefix}${flag#+}"

		IUSE+=" ${is_default}${fullname}"

		${has_requirement} && REQUIRED_USE+="
			${fullname}? ( ${requirement} )"
	done
}

expand_iuse "${IUSE_ENLIGHTENMENT_MODULES}" "enlightenment_modules_"

src_prepare() {
	#remove useless startup checks since we know we have the deps
	epatch "${FILESDIR}/quickstart.diff" || die
	#epatch "${FILESDIR}/wayland-only.patch" || die

	efl_src_prepare
}

src_configure() {
	export MY_ECONF="
	  ${MY_ECONF}
	  --disable-install-sysactions
	  $(use_enable pam)
	  $(use_enable systemd)
	  $(use_enable eeze mount-eeze)
	  $(use_enable udev device-udev)
	  $(use_enable udisks mount-udisks)
	  $(use_enable sysactions install-sysactions)
"
      if use wayland; then
          MY_ECONF+="
            --enable-wayland
            --enable-wayland-egl
            --enable-wl-desktop-shell
            --enable-wl-text-input 
            --enable-wl-wl
            --enable-wl-drm 
            "
          if use X; then
            MY_ECONF+=" --enable-xwayland --enable-wl-x11"
          else
            MY_ECONF+=" --disable-wl-x11 --enable-wayland-only"
          fi
      fi

	local module=

	for module in ${IUSE_ENLIGHTENMENT_MODULES}; do
		module="${module#+}"
		MY_ECONF+=" $(use_enable enlightenment_modules_${module} ${module})"
	done

	efl_src_configure
}

src_install() {
	efl_src_install
	insinto /etc/enlightenment

	newins "${FILESDIR}/gentoo-sysactions.conf" sysactions.conf

	if use debug; then
		einfo "Registering gdb into your /etc/enlightenment/sysactions.conf"

		echo "action: gdb /usr/bin/gdb" >>				\
							${D}/etc/enlightenment/sysactions.conf
	fi
}

# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools eutils verify-git-sig

DESCRIPTION="Suspend and hibernation utilities"
HOMEPAGE="https://pm-utils.freedesktop.org/"

EGIT_REPO_URI="https://github.com/halcon74/pm-utils.git"
EGIT_BRANCH="pm-utils-1.4"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug +logrotate video_cards_intel video_cards_radeon"

RESTRICT="mirror"

VERIFY_GIT_SIG_OPENPGP_KEY_PATH="/usr/share/openpgp-keys/halcon.asc"
VERIFY_SIG_OPENPGP_KEY_PATH="/usr/share/openpgp-keys/halcon.asc"

vbetool="!video_cards_intel? ( sys-apps/vbetool )"
RDEPEND="
	!<app-laptop/laptop-mode-tools-1.55-r1
	!sys-power/pm-quirks
	!sys-power/powermgmt-base[-pm-utils(+)]
	sys-apps/dbus
	>=sys-apps/util-linux-2.13
	amd64? ( ${vbetool} )
	x86? ( ${vbetool} )
	logrotate? ( app-admin/logrotate )
	video_cards_radeon? ( sys-apps/radeontool )
"
DEPEND="
	${RDEPEND}
	verify-git-sig? ( >=app-crypt/openpgp-keys-pm-utils-20210206 )
"

DOCS="AUTHORS ChangeLog NEWS pm/HOWTO* README* TODO"

src_prepare() {
	default

	eautoreconf

	local ignore="01grub"
	use debug && echo 'PM_DEBUG="true"' > "${T}"/gentoo
	echo "HOOK_BLACKLIST=\"${ignore}\"" >> "${T}"/gentoo
}

src_configure() {
	econf
}

src_compile() {
	default

	make ChangeLog
}

src_install() {
	default

	doman man/*.{1,8}

	insinto /etc/pm/config.d
	doins "${T}"/gentoo

	if use logrotate ; then
		mv debian/${PN}.logrotate debian/${PN}
		insinto /etc/logrotate.d
		doins debian/${PN} #408091
	fi

	rm -rf "${ED}"/etc/video-quirks

	# Remove hooks which are not stable enough yet (rm -f from debian/rules)
	rm -f "${ED}"/usr/$(get_libdir)/${PN}/power.d/harddrive || die "removing unstable hook 'hardrive' failed"

	# Change to executable (chmod +x from debian/rules)
	fperms +x /usr/$(get_libdir)/${PN}/defaults || die "changing to executable failed"
}

# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome2 autotools flag-o-matic

MY_P=${P}
S=${WORKDIR}/${MY_P}

DESCRIPTION="SyncEvolution synchronizes personal information management (PIM) data such as contacts, appointments, tasks and memos using the Synthesis sync engine, which provides support for the SyncML synchronization protocol."
HOMEPAGE="http://syncevolution.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="dbus gtk kde bluetooth gnome-keyring goa sqlite libnotify"

SRC_URI="http://downloads.syncevolution.org/syncevolution/sources/${MY_P}.tar.gz"

RESTRICT="mirror"

RDEPEND=">=gnome-base/gconf-2
	>=dev-libs/glib-2.8
	gtk? ( x11-libs/gtk+:3 )
	net-libs/libsoup:2.4
	>=gnome-extra/evolution-data-server-1.2
	dev-db/sqlite
	dbus? ( dev-libs/folks app-i18n/libphonenumber )
	kde? ( app-office/akonadi-server kde-base/kwallet )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35
	dev-util/cppunit
"


DOCS="AUTHORS ChangeLog"

src_prepare() {
	append-cxxflags -std=gnu++98
	sed -i \
		-e 's/unique-1\.0/unique-3\.0/g' \
		configure.ac || die "sed failed"
	pushd src/synthesis
	epatch "${FILESDIR}"/synthesis/*.patch
	popd

	epatch "${FILESDIR}"/0001-Fix-FTBFS-on-kfreebsd-due-to-missing-SOCK_CLOEXEC.patch
	epatch "${FILESDIR}"/0002-Avoid-register-unecessary-timezones.patch
	epatch "${FILESDIR}"/0003-Add-missing-casts-from-shared_ptr-to-bool-to-fix-FTB.patch
	epatch "${FILESDIR}"/fix-photo-merging.patch
	epatch "${FILESDIR}"/calendar-limit-date-sync.diff
	epatch "${FILESDIR}"/Use-90-days-as-default-value-for-syncInterval.patch
	epatch "${FILESDIR}"/Handle-error-403-from-google-calendar.patch
	epatch "${FILESDIR}"/syncevolution-1.5.1-libical2.patch
	epatch "${FILESDIR}"/e_book_client-timeout.patch

	eautoreconf
	default
}

src_configure() {
    econf \
    $(use_enable dbus dbus-service) \
	$(use_enable kde akonadi) \
	$(use_enable kde kwallet) \
	$(use_enable gtk gui=gtk) \
	$(use_enable gtk gtk=3) \
	$(use_enable bluetooth) \
	$(use_enable bluetooth pbap) \
	$(use_enable libnotify notify) \
	$(use_enable sqlite) \
	$(use_enable gnome-keyring) \
	$(use_enable goa) \
	$(use_enable dbus dbus-service-pim) \
    --enable-libsoup \
    --enable-core \
    || die "configure failed"

}

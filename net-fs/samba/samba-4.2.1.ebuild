# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/samba/samba-4.2.0.ebuild,v 1.1 2015/03/08 13:21:55 polynomial-c Exp $

EAPI=5
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE='threads(+)'

inherit python-single-r1 waf-utils multilib multilib-minimal linux-info systemd

MY_PV="${PV/_rc/rc}"
MY_P="${PN}-${MY_PV}"

SRC_PATH="stable"
[[ ${PV} = *_rc* ]] && SRC_PATH="rc"

SRC_URI="mirror://samba/${SRC_PATH}/${MY_P}.tar.gz"
KEYWORDS="~amd64 ~hppa ~x86"
[[ ${PV} = *_rc* ]] && KEYWORDS=""

DESCRIPTION="Samba Suite Version 4"
HOMEPAGE="http://www.samba.org/"
LICENSE="GPL-3"

SLOT="0"

IUSE="acl addns ads aio avahi bi_heimdal client cluster cups dmapi fam gnutls iprint
ldap quota selinux syslog systemd test winbind"

# sys-apps/attr is an automagic dependency (see bug #489748)
# sys-libs/pam is an automagic dependency (see bug #489770)
CDEPEND="${PYTHON_DEPS}
	!bi_heimdal? ( >=app-crypt/heimdal-1.5[-ssl] )
	dev-libs/iniparser[${MULTILIB_USEDEP}]
	dev-libs/popt
	sys-libs/readline:=
	virtual/libiconv[${MULTILIB_USEDEP}]
	dev-python/subunit[${PYTHON_USEDEP},${MULTILIB_USEDEP}]
	>=net-libs/socket_wrapper-1.1.2[${MULTILIB_USEDEP}]
	sys-apps/attr
	sys-libs/libcap[${MULTILIB_USEDEP}]
	>=sys-libs/ldb-1.1.20[${MULTILIB_USEDEP}]
	>=sys-libs/nss_wrapper-1.0.2[${MULTILIB_USEDEP}]
	>=sys-libs/ntdb-1.0[python,${PYTHON_USEDEP},${MULTILIB_USEDEP}]
	>=sys-libs/talloc-2.1.1[python,${PYTHON_USEDEP},${MULTILIB_USEDEP}]
	>=sys-libs/tdb-1.3.4[python,${PYTHON_USEDEP},${MULTILIB_USEDEP}]
	>=sys-libs/tevent-0.9.24[${MULTILIB_USEDEP}]
	>=sys-libs/uid_wrapper-1.0.1[${MULTILIB_USEDEP}]
	>=app-arch/libarchive-3.1.2[${MULTILIB_USEDEP}]
	sys-libs/zlib[${MULTILIB_USEDEP}]
	virtual/pam[${MULTILIB_USEDEP}]
	acl? ( virtual/acl )
	addns? ( net-dns/bind-tools[gssapi] )
	bi_heimdal? ( !>=app-crypt/heimdal-1.5[-ssl] )
	aio? ( dev-libs/libaio[${MULTILIB_USEDEP}] )
	cluster? ( >=dev-db/ctdb-1.0.114_p1 )
	cups? ( net-print/cups )
	dmapi? ( sys-apps/dmapi )
	fam? ( virtual/fam[${MULTILIB_USEDEP}] )
	gnutls? ( dev-libs/libgcrypt:0[${MULTILIB_USEDEP}]
		>=net-libs/gnutls-1.4.0[${MULTILIB_USEDEP}] )
	ldap? ( net-nds/openldap[${MULTILIB_USEDEP}] )
	systemd? ( sys-apps/systemd:0= )"
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}
	client? ( net-fs/cifs-utils[ads?] )
	selinux? ( sec-policy/selinux-samba )
"

REQUIRED_USE="ads? ( acl ldap )
	${PYTHON_REQUIRED_USE}"

RESTRICT="mirror"

S="${WORKDIR}/${MY_P}"

CONFDIR="${FILESDIR}/$(get_version_component_range 1-2)"

WAF_BINARY="${S}/buildtools/bin/waf"

samba_build_with_python() {
	if ! multilib_is_native_abi; then
		pushd "${BUILD_DIR}"
		epatch "${FILESDIR}"/waf-disable-python.patch
		popd
	fi
}

src_prepare() {
	epatch_user
	multilib_copy_sources
	multilib_foreach_abi samba_build_with_python
}

pkg_setup() {
	python-single-r1_pkg_setup
	if use aio; then
		if ! linux_config_exists || ! linux_chkconfig_present AIO; then
				ewarn "You must enable AIO support in your kernel config, "
				ewarn "to be able to support asynchronous I/O. "
				ewarn "You can find it at"
				ewarn
				ewarn "General Support"
				ewarn " Enable AIO support "
				ewarn
				ewarn "and recompile your kernel..."
		fi
	fi
}

multilib_src_configure() {
	local myconf=''
	use "cluster" && myconf+=" --with-ctdb-dir=/usr"
	use "test" && myconf+=" --enable-selftest"
	if use "bi_heimdal"; then
		myconf+=" --bundled-libraries=heimdal"
	else
		myconf+=" --bundled-libraries=NONE"
	fi
	myconf="${myconf} \
		--enable-fhs \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--with-modulesdir=/usr/$(get_libdir)/samba \
		--with-pammodulesdir=/$(get_libdir)/security \
		--with-piddir=/var/run/${PN} \
		--disable-rpath \
		--disable-rpath-install \
		--nopyc \
		--nopyo \
		--builtin-libraries=NONE \
		$(multilib_native_use_with addns dnsupdate) \
		$(multilib_native_use_with acl acl-support) \
		$(use_with ads) \
		$(use_with aio aio-support) \
		$(multilib_native_use_enable avahi) \
		$(use_with cluster cluster-support) \
		$(multilib_native_use_enable cups) \
		$(use_with dmapi) \
		$(use_with fam) \
		$(use_enable gnutls) \
		$(multilib_native_use_enable iprint) \
		$(use_with ldap) \
		--with-pam \
		--with-pam_smbpass \
		$(use_with quota quotas) \
		$(use_with syslog) \
		$(use_with systemd) \
		$(use_with winbind)
		"
	use "ads" && myconf+=" --with-shared-modules=idmap_ad"

	CPPFLAGS="-I/usr/include/et ${CPPFLAGS}" \
		waf-utils_src_configure ${myconf}
}

multilib_src_install() {
	waf-utils_src_install
}

multilib_src_install_all() {
	# install ldap schema for server (bug #491002)
	if use ldap ; then
		insinto /etc/openldap/schema
		doins examples/LDAP/samba.schema
	fi

	# Make all .so files executable
	find "${D}" -type f -name "*.so" -exec chmod +x {} +

	# Install init script and conf.d file
	newinitd "${CONFDIR}/samba4.initd-r1" samba
	newconfd "${CONFDIR}/samba4.confd" samba

	systemd_dotmpfilesd "${FILESDIR}"/samba.conf
	systemd_dounit "${FILESDIR}"/nmbd.service
	systemd_dounit "${FILESDIR}"/smbd.{service,socket}
	systemd_newunit "${FILESDIR}"/smbd_at.service 'smbd@.service'
	systemd_dounit "${FILESDIR}"/winbindd.service
	systemd_dounit "${FILESDIR}"/samba.service
}

src_test() {
	"${WAF_BINARY}" test || die "test failed"
}

pkg_postinst() {
	ewarn "Be aware the this release contains the best of all of Samba's"
	ewarn "technology parts, both a file server (that you can reasonably expect"
	ewarn "to upgrade existing Samba 3.x releases to) and the AD domain"
	ewarn "controller work previously known as 'samba4'."

	elog "For further information and migration steps make sure to read "
	elog "http://samba.org/samba/history/${P}.html "
	elog "http://samba.org/samba/history/${PN}-4.0.0.html and"
	elog "http://wiki.samba.org/index.php/Samba4/HOWTO "
}

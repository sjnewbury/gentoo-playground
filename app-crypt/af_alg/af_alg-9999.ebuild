# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils flag-o-matic git-r3 linux-info autotools

DESCRIPTION="AF_ALG for OpenSSL"
HOMEPAGE="http://carnivore.it/2011/04/23/openssl_-_af_alg"

EGIT_REPO_URI="https://github.com/RidgeRun/af-alg-rr.git"
EGIT_COMMIT="HEAD"

LICENSE="openssl"
SLOT="0"
KEYWORDS=""
IUSE="debug"

DEPEND="dev-libs/openssl:0"
RDEPEND="${DEPEND}"

CONFIG_CHECK="~CONFIG_CRYPTO_USER_API
	~CRYPTO_USER_API_HASH
	~CRYPTO_USER_API_SKCIPHER"
WARNING_CONFIG_CRYPTO_USER_API="You must enable CONFIG_CRYPTO_USER_API in your kernel, otherwise ${PN} would not work"
WARNING_CRYPTO_USER_API_HASH="You must enable CRYPTO_USER_API_HASH in your kernel, otherwise ${PN} would not work"
WARNING_CRYPTO_USER_API_SKCIPHER="You must enable CRYPTO_USER_API_SKCIPHER in your kernel, otherwise ${PN} would not work"

src_prepare() {
#	epatch "${FILESDIR}/0001-MEDIUM-BUILD-Use-CC-instead-of-LD-to-link-library.patch"
#	epatch "${FILESDIR}/0002-MEDIUM-BUILD-Do-not-override-variable-if-already-def.patch"
#	epatch "${FILESDIR}/0003-MINOR-BUILD-Comment-some-Makefile-tips-usages.patch"
#	epatch "${FILESDIR}/0004-MINOR-BUILD-Rename-EXTRA_FILES-to-DOC_FILES.patch"
#	epatch "${FILESDIR}/0005-MEDIUM-BUILD-Implement-make-install.patch"
#	epatch "${FILESDIR}/0006-MINOR-BUILD-The-usage-of-Tab-is-recommenced-in-Makef.patch"

	# fix openssl plugin dir
	sed -i \
		-e '/  plugindir=/s/openssl-1.0.0\/engines/engines/' \
		configure.ac || die sed failed

	eautoreconf

	if use debug ; then
		einfo "Appending to CFLAGS: -DDEBUG"
		append-cflags -DDEBUG
	fi
}

src_install() {
	emake install \
		DESTDIR="${ED}" LIBDIR="/usr/$(get_libdir)/engines"

	dodoc README
}

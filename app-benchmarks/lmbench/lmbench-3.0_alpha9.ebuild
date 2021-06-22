# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-benchmarks/lmbench/Attic/lmbench-3_alpha3.ebuild,v 1.3 2009/04/29 00:52:17 dragonheart dead $

EAPI=6

inherit toolchain-funcs eutils flag-o-matic

MY_P=${P/_alpha/-a}
DESCRIPTION="Suite of simple, portable benchmarks"
HOMEPAGE="http://www.bitmover.com/lmbench/whatis_lmbench.html"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc sparc x86"
IUSE=""

DEPEND="net-libs/libtirpc"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}"/rename-line-binary.patch
	"${FILESDIR}"/update-results-script.patch
	"${FILESDIR}"/obey-ranlib.patch
	"${FILESDIR}"/update-config-script.patch
	"${FILESDIR}"/use-base_libdir-instead-of-hardcoded-lib.patch
	"${FILESDIR}"/lmbench_result_html_report.patch
	"${FILESDIR}"/fix-lmbench-memory-check-failure.patch
	"${FILESDIR}"/0001-avoid-gcc-optimize-away-the-loops.patch
)

src_compile() {
	filter-flags -flto*
	append-cflags $(pkg-config --cflags libtirpc)
	append-libs $(pkg-config --libs libtirpc)

	sed -e "s#^my \$distro =.*#my \$distro = \"`uname -r`\";#" \
		-e 's#^@files =#chdir "/usr/share/lmbench"; @files =#' \
		-e "s#../../CONFIG#/etc/bc-config#g" "${FILESDIR}"/bc_lm.pl > bc_lm.pl
	sed -i -e "s:-O:\"${CFLAGS}\":" src/Makefile
	sed -i -e "/LDLIBS/s/\(-lm\)/\"\1 ${LIBS}\"/" scripts/build || die "sed scripts/build failed"

	emake CC=$(tc-getCC) MAKE=make OS=`scripts/os` || die "emake failed"
}

src_install() {
	cd src ; emake base_libdir="/$(get_libdir)" CC=$(tc-getCC) MAKE=make BASE="${D}"/usr install || die

	dodir /usr/share
	mv "${D}"/usr/man "${D}"/usr/share

	cd "${S}"
	exeinto /usr/bin
	doexe "${S}"/bc_lm.pl
	#doexe "${FILESDIR}"/lmbench-run

	mv "${D}"/usr/bin/stream "${D}"/usr/bin/stream.lmbench

	insinto /etc
	doins "${FILESDIR}"/bc-config

	dodir /usr/share/lmbench
	dodir /usr/share/lmbench/src
	cp src/webpage-lm.tar "${D}"/usr/share/lmbench/src
	cp -R scripts "${D}"/usr/share/lmbench

	dodir /usr/share/lmbench/results
	chmod 777 "${D}"/usr/share/lmbench/results
	dodir /usr/share/lmbench/bin
	chmod 777 "${D}"/usr/share/lmbench/bin

	# avoid file collision with sys-apps/util-linux
	mv "${D}"/usr/bin/line "${D}"/usr/bin/lm_line
}

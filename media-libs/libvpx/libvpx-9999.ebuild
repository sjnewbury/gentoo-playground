# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libvpx/libvpx-9999.ebuild,v 1.53 2015/02/05 16:00:23 mgorny Exp $

EAPI=7
inherit toolchain-funcs multilib-minimal

LIBVPX_TESTDATA_VER=1.9.0

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://chromium.googlesource.com/webm/${PN}.git"
elif [[ ${PV} == *pre* ]]; then
	SRC_URI="mirror://gentoo/${P}.tar.bz2"
	KEYWORDS="~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
else
	SRC_URI="https://github.com/webmproject/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux"
fi
# generated by: make LIBVPX_TEST_DATA_PATH=libvpx-testdata testdata + tar'ing
# it.
SRC_URI="${SRC_URI}
		test? ( https://dev.gentoo.org/~whissi/dist/libvpx/${PN}-testdata-${LIBVPX_TESTDATA_VER}.tar.xz )"

DESCRIPTION="WebM VP8 and VP9 Codec SDK"
HOMEPAGE="http://www.webmproject.org"

LICENSE="BSD"
SLOT="0/7"
IUSE="cpu_flags_x86_avx cpu_flags_x86_avx2 doc cpu_flags_x86_mmx postproc cpu_flags_x86_sse cpu_flags_x86_sse2 cpu_flags_x86_sse3 cpu_flags_x86_ssse3 cpu_flags_x86_sse4_1 doc +highbitdepth postproc static-libs svc test +threads"

RDEPEND="abi_x86_32? ( !app-emulation/emul-linux-x86-medialibs[-abi_x86_32(-)] )"
DEPEND="abi_x86_32? ( dev-lang/yasm )
	abi_x86_64? ( dev-lang/yasm )
	abi_x86_x32? ( dev-lang/yasm )
	doc? (
		app-doc/doxygen
		dev-lang/php
	)
"

REQUIRED_USE="
	cpu_flags_x86_sse2? ( cpu_flags_x86_mmx )
	cpu_flags_x86_ssse3? ( cpu_flags_x86_sse2 )
	test? ( threads )"

src_prepare() {
	[[ ${PV} != *9999* ]] && eapply "${FILESDIR}/libvpx-1.3.0-sparc-configure.patch" # 501010
	eapply "${FILESDIR}/${PN}-1.8.2-missing-c-fallback.patch"
	eapply "${FILESDIR}/${PN}-1.6.1-x32.patch"
	default
}

src_configure() {
	# https://bugs.gentoo.org/show_bug.cgi?id=384585
	# https://bugs.gentoo.org/show_bug.cgi?id=465988
	# copied from php-pear-r1.eclass
	addpredict /usr/share/snmp/mibs/.index
	addpredict /var/lib/net-snmp/
	addpredict /var/lib/net-snmp/mib_indexes
	addpredict /session_mm_cli0.sem
	multilib-minimal_src_configure
}

multilib_src_configure() {
	unset CODECS #357487

	# #498364: sse doesn't work without sse2 enabled,
	local myconfargs=(
		--prefix="${EPREFIX}"/usr
		--libdir="${EPREFIX}"/usr/$(get_libdir)
		--enable-pic
		--enable-vp8
		--enable-vp9
		--enable-shared
		--disable-runtime-cpu-detect
		--extra-cflags="${CFLAGS}"
		$(use_enable cpu_flags_x86_avx avx)
		$(use_enable cpu_flags_x86_avx2 avx2)
		$(use_enable cpu_flags_x86_mmx mmx)
		$(use cpu_flags_x86_sse2 && use_enable cpu_flags_x86_sse sse || echo --disable-sse)
		$(use_enable cpu_flags_x86_sse2 sse2)
		$(use_enable cpu_flags_x86_sse3 sse3)
		$(use_enable cpu_flags_x86_sse4_1 sse4_1)
		$(use_enable cpu_flags_x86_ssse3 ssse3)
		$(use_enable postproc)
		$(use_enable svc experimental)
		$(use_enable static-libs static)
		$(use_enable test unit-tests)
		$(use_enable threads multithread)
		$(use_enable highbitdepth vp9-highbitdepth)
		${myconf}
	)

	# let the build system decide which AS to use (it honours $AS but
	# then feeds it with yasm flags without checking...) #345161
	tc-export AS
	case "${CHOST}" in
		i?86*) export AS=yasm;;
		x86_64*) export AS=yasm;;
	esac

	# powerpc toolchain is not recognized anymore, #694368
	[[ ${CHOST} == powerpc-* ]] && myconfargs+=( --force-target=generic-gnu )

	# Build with correct toolchain.
	tc-export CC CXX AR NM
	# Link with gcc by default, the build system should override this if needed.
	export LD="${CC}"

	if multilib_is_native_abi; then
		myconfargs+=( $(use_enable doc install-docs) $(use_enable doc docs) )
	else
		# not needed for multilib and will be overwritten anyway.
		myconfargs+=( --disable-examples --disable-install-docs --disable-docs )
	fi

	echo "${S}"/configure "${myconfargs[@]}" >&2
	"${S}"/configure "${myconfargs[@]}"
}

multilib_src_compile() {
	# build verbose by default and do not build examples that will not be installed
	emake verbose=yes GEN_EXAMPLES=
}

multilib_src_test() {
	local -x LD_LIBRARY_PATH="${BUILD_DIR}"
	local -x LIBVPX_TEST_DATA_PATH="${WORKDIR}/${PN}-testdata"
	emake verbose=yes GEN_EXAMPLES= test
}

multilib_src_install() {
	emake verbose=yes GEN_EXAMPLES= DESTDIR="${D}" install
	multilib_is_native_abi && use doc && dodoc -r docs/html
}

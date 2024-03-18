# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SCM=""

if [ "${PV#9999}" != "${PV}" ] ; then
        SCM="git-r3"
        EGIT_REPO_URI="https://github.com/sekrit-twc/zimg"
fi

inherit autotools multilib-minimal ${SCM}

DESCRIPTION="Scaling, colorspace conversion, and dithering library"
HOMEPAGE="https://github.com/sekrit-twc/zimg"

if [ "${PV#9999}" = "${PV}" ] ; then
        SRC_URI="https://github.com/sekrit-twc/zimg/archive/release-${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~ia64 ppc ppc64 sparc x86"
        S="${WORKDIR}/${PN}-release-${PV}/"
fi

LICENSE="WTFPL-2"
SLOT="0"
IUSE="static-libs cpu_flags_x86_sse cpu_flags_x86_avx2 cpu_flags_x86_avx512f"

PATCHES=("${FILESDIR}/${PN}-optional-avx2-r7.patch")

DEPEND=""
RDEPEND="${DEPEND}"

ECONF_SOURCE="${S}"

src_prepare() {
        default
        eautoreconf
}

multilib_src_configure() {
        if !(use cpu_flags_x86_avx512f); then
                # avx512 support breaks build due to abi violation with
                # unsupported "-march"
		export ax_cv_check_cflags___mavx512f__mavx512pf__mavx512er__mavx512cd__mavx512vl__mavx512bw__mavx512dq__mavx512ifma__mavx512vbmi=no
		export ax_cv_check_cflags___mavx512f__mavx512pf__mavx512er__mavx512cd__mavx512vl__mavx512bw__mavx512dq__mavx512ifma__mavx512vbmi__mavx512vbmi2__mavx512bitalg__mavx512vpopcntdq__mavx512vnni=no
        fi
        if !(use cpu_flags_x86_avx2); then
                export ax_cv_check_cflags___mavx2=no
        fi
        econf $(use_enable cpu_flags_x86_sse simd)
}

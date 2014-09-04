# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

GCC_FILESDIR="${PORTDIR}/sys-devel/gcc/files"
gcc_LIVE_BRANCH="gcc-4_9-branch"
#gcc_LIVE_BRANCH=master

inherit multilib toolchain

DESCRIPTION="The GNU Compiler Collection."

LICENSE="GPL-3 LGPL-3 || ( GPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.2"
KEYWORDS=""

SLOT="${GCC_BRANCH_VER}-vcs"
IUSE="debug nobootstrap offline"

RDEPEND=""
DEPEND="${RDEPEND}
	>=${CATEGORY}/binutils-2.18"

if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.12 )"
fi

src_unpack() {
	# use the offline USE flag to prevent the ebuild from trying to update from
	# the repo.  the current sources will be used instead.
	use offline && EVCS_OFFLINE="yes"

	toolchain_src_unpack

	echo "commit ${EGIT_VERSION}" > "${S}"/gcc/REVISION
}

src_prepare() {
	toolchain_src_prepare

	if ! use vanilla ; then
		# drop-in patches
		if [[ -e ${FILESDIR}/${GCC_RELEASE_VER} ]]; then
			EPATCH_SOURCE="${FILESDIR}/${GCC_RELEASE_VER}" \
			EPATCH_EXCLUDE="${FILESDIR}/${GCC_RELEASE_VER}/exclude" \
			EPATCH_FORCE="yes" EPATCH_SUFFIX="patch" epatch
		fi

		[[ ${CHOST} == ${CTARGET} ]] && epatch "${GCC_FILESDIR}"/gcc-spec-env-r1.patch
	fi

	use debug && GCC_CHECKS_LIST="yes"

	# single-stage build for quick patch testing
	if use nobootstrap; then
		GCC_MAKE_TARGET="all"
		EXTRA_ECONF+=" --disable-bootstrap"
	fi
}

pkg_postinst() {
	toolchain_pkg_postinst
	echo
	einfo "This GCC ebuild is provided for your convenience, and the use"
	einfo "of this compiler is not supported by the Gentoo Developers."
	einfo "Please report bugs to upstream at http://gcc.gnu.org/bugzilla/"
	echo
}

# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: verify-git-sig.eclass
# @MAINTAINER:
# Alexey Mishustin <halcon@tuta.io>
# @AUTHOR:
# Vladimir Timofeenko <overlay.maintain@vtimofeenko.com>
# Alexey Mishustin <halcon@tuta.io>
# @BLURB: Allows verifying signature on top commit
# @DESCRIPTION:
# This eclass provides the ability to verify the signature on the
# top commit of repository checked out by git-r3.
# The interfaces exposed by this eclass aim to mimick the behavior
# of verify-sig.eclass.
#
#
# Example use:
# @CODE
# inherit verify-git-sig
#
# EGIT_REPO_URI="https://example.org/author/repository.git"
# EGIT_BRANCH="some-non-default-branch"
# BDEPEND="
#   verify-git-sig? ( app-crypt/openpgp-keys-example )"
#
# VERIFY_GIT_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/example.asc
#
# @CODE
# This will use the default git-r3_src_unpack to get the repo and
# verify the signature on the top commit.
# Alternatively, use verify-git-sig_verify-commit <git-directory> [<key-file>]
# specifying the directory where to verify the commit and, optionally, the key to verify against.

if [[ ! ${_GIT_VERIFY_SIG_ECLASS} ]]; then

case "${EAPI:-0}" in
	0|1|2|3|4|5|6)
		die "Unsupported EAPI=${EAPI} (obsolete) for ${ECLASS}"
		;;
	7)
		;;
	*)
		die "Unsupported EAPI=${EAPI} (unknown) for ${ECLASS}"
		;;
esac

EXPORT_FUNCTIONS src_unpack

inherit git-r3

IUSE="verify-git-sig"

BDEPEND="
	verify-git-sig? (
		app-crypt/gnupg
		>=app-portage/gemato-16
	)"

# @ECLASS-VARIABLE: VERIFY_GIT_SIG_OPENPGP_KEY_PATH
# @DEFAULT_UNSET
# @DESCRIPTION:
# Path to key bundle used to perform the verification.  This is required
# when using default src_unpack.  Alternatively, the key path can be
# passed directly to the verification functions.

# @FUNCTION: verify-git-sig_src_unpack
# @DESCRIPTION:
# Default src_unpack override that verifies signature for the
# newest (HEAD) commit if 'verify-git-sig' flag is enabled.  The function dies if the
# signatures fails to verify or the commit not signed.
verify-git-sig_src_unpack() {
	git-r3_src_unpack
	if use verify-git-sig; then
		verify-git-sig_verify-commit "${EGIT_CHECKOUT_DIR:-${WORKDIR}/${P}}"
	fi
}

# @FUNCTION: verify-git-sig_verify-commit
# @USAGE: <git-directory> [<key-file>]
# @DESCRIPTION:
# Verifies the newest (HEAD) commit in the supplied directory
# using the supplied key file
verify-git-sig_verify-commit() {
	local git_dir=${1}
	local key=${2:-${VERIFY_GIT_SIG_OPENPGP_KEY_PATH}}

	[[ -n ${key} ]] ||
		die "${FUNCNAME}: no key passed and VERIFY_GIT_SIG_OPENPGP_KEY_PATH unset"

	local extra_args=( "-R" )

	gemato gpg-wrap -K "${key}" "${extra_args[@]}" -- \
		git --work-tree="${git_dir}" --git-dir="${git_dir}"/.git verify-commit HEAD ||
		die "Git commit verification failed"
}

_GIT_VERIFY_SIG_ECLASS=1
fi

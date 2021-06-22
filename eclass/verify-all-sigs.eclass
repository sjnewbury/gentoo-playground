# Copyright 2020-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: verify-all-sigs.eclass
# @MAINTAINER:
# Alexey Mishustin <halcon@tuta.io>
# @SUPPORTED_EAPIS: 7
# @BLURB: Eclass to verify upstream signatures on distfiles AND/OR git signatures on top commit
# @DESCRIPTION:
# verify-all-sigs eclass provides:
#
#  - A streamlined approach to verifying
# upstream signatures on distfiles.  Its primary purpose is to permit
# developers to easily verify signatures while bumping packages.
# The eclass removes the risk of developer forgetting to perform
# the verification, or performing it incorrectly, e.g. due to additional
# keys in the local keyring.  It also permits users to verify
# the developer's work.
#
# - The ability to verify the signature on the
# top commit of repository checked out by git-r3.
#
# To use the eclass, start by packaging the upstream's releases/commits keys
# as app-crypt/openpgp-keys-*.  Then inherit the eclass.
# For release signatures: add detached releases
# signatures to SRC_URI and set VERIFY_SIG_OPENPGP_KEY_PATH.  The eclass
# provides verify-sig USE flag to toggle the verification.
# For commit signatures: add EGIT_REPO_URI (and  optionally EGIT_BRANCH),
# set VERIFY_GIT_SIG_OPENPGP_KEY_PATH. The eclass
# provides verify-git-sig USE flag to toggle the verification.
#
# Example use:
# @CODE
#
# Option 1. For release signatures only (not 9999 ebuilds): 
#
# inherit verify-all-sigs
#
# SRC_URI="https://example.org/${P}.tar.gz
#   verify-sig? ( https://example.org/${P}.tar.gz.sig )"
# BDEPEND="
#   verify-sig? ( app-crypt/openpgp-keys-example )"
#
# VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/example.asc
#
# Option 2. For commit signatures only (9999 ebuilds):
#
# inherit verify-all-sigs
#
# EGIT_REPO_URI="https://example.org/author/repository.git"
# EGIT_BRANCH="some-non-default-branch"
# BDEPEND="
#   verify-git-sig? ( app-crypt/openpgp-keys-example )"
#
# VERIFY_GIT_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/example.asc
#
# Option 3. For both commit and release signatures (9999 ebuilds):
#
# inherit verify-all-sigs
#
# EGIT_REPO_URI="https://example.org/author/repository.git"
# EGIT_BRANCH="some-non-default-branch"
# BDEPEND="
#   verify-git-sig? ( app-crypt/openpgp-keys-example1 )"
#   verify-sig? ( app-crypt/openpgp-keys-example2 )"
#
# VERIFY_GIT_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/example1.asc
# VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/example2.asc
#
# @CODE

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

if [[ ! ${_VERIFY_ALL_SIGS_ECLASS} ]]; then

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	IUSE="verify-sig verify-git-sig"
	BDEPEND="
		verify-sig? (
			app-crypt/gnupg
			>=app-portage/gemato-16
		)
		verify-git-sig? (
			app-crypt/gnupg
			>=app-portage/gemato-16
		)
	"
else
	IUSE="verify-sig"
	BDEPEND="
		verify-sig? (
			app-crypt/gnupg
			>=app-portage/gemato-16
		)
	"
fi

# @ECLASS-VARIABLE: VERIFY_SIG_OPENPGP_KEY_PATH
# @DEFAULT_UNSET
# @DESCRIPTION:
# Path to key bundle used to perform the release verification.  This is required
# when using default src_unpack.  Alternatively, the key path can be
# passed directly to the verification functions.

# @ECLASS-VARIABLE: VERIFY_GIT_SIG_OPENPGP_KEY_PATH
# @DEFAULT_UNSET
# @DESCRIPTION:
# Path to key bundle used to perform the commit verification.  This is required
# when using default src_unpack.  Alternatively, the key path can be
# passed directly to the verification functions.

# @ECLASS-VARIABLE: VERIFY_SIG_OPENPGP_KEYSERVER
# @DEFAULT_UNSET
# @DESCRIPTION:
# Keyserver used to refresh keys (so far only for release keys).  If not specified, the keyserver
# preference from the key will be respected.  If no preference
# is specified by the key, the GnuPG default will be used.

# @ECLASS-VARIABLE: VERIFY_SIG_OPENPGP_KEY_REFRESH
# @USER_VARIABLE
# @DESCRIPTION:
# Attempt to refresh keys via WKD/keyserver (so far only for release keys).  Set it to "yes"
# in make.conf to enable.  Note that this requires working Internet
# connection.
: ${VERIFY_SIG_OPENPGP_KEY_REFRESH:=no}

# @FUNCTION: verify-all-sigs_verify_detached
# @USAGE: <file> <sig-file> [<key-file>]
# @DESCRIPTION:
# Read the detached signature from <sig-file> and verify <file> against
# it.  <key-file> can either be passed directly, or it defaults
# to VERIFY_SIG_OPENPGP_KEY_PATH.  The function dies if verification
# fails.
verify-all-sigs_verify_detached() {
	local file=${1}
	local sig=${2}
	local key=${3:-${VERIFY_SIG_OPENPGP_KEY_PATH}}

	[[ -n ${key} ]] ||
		die "${FUNCNAME}: no key passed and VERIFY_SIG_OPENPGP_KEY_PATH unset"

	local extra_args=()
	[[ ${VERIFY_SIG_OPENPGP_KEY_REFRESH} == yes ]] || extra_args+=( -R )
	[[ -n ${VERIFY_SIG_OPENPGP_KEYSERVER+1} ]] && extra_args+=(
		--keyserver "${VERIFY_SIG_OPENPGP_KEYSERVER}"
	)

	# GPG upstream knows better than to follow the spec, so we can't
	# override this directory.  However, there is a clean fallback
	# to GNUPGHOME.
	addpredict /run/user

	local filename=${file##*/}
	[[ ${file} == - ]] && filename='(stdin)'
	einfo "Verifying ${filename} ..."
	gemato gpg-wrap -K "${key}" "${extra_args[@]}" -- \
		gpg --verify "${sig}" "${file}" ||
		die "PGP signature verification failed"
}

# @FUNCTION: verify-all-sigs_verify_message
# @USAGE: <file> <output-file> [<key-file>]
# @DESCRIPTION:
# Verify that the file ('-' for stdin) contains a valid, signed PGP
# message and write the message into <output-file> ('-' for stdout).
# <key-file> can either be passed directly, or it defaults
# to VERIFY_SIG_OPENPGP_KEY_PATH.  The function dies if verification
# fails.  Note that using output from <output-file> is important as it
# prevents the injection of unsigned data.
verify-all-sigs_verify_message() {
	local file=${1}
	local output_file=${2}
	local key=${3:-${VERIFY_SIG_OPENPGP_KEY_PATH}}

	[[ -n ${key} ]] ||
		die "${FUNCNAME}: no key passed and VERIFY_SIG_OPENPGP_KEY_PATH unset"

	local extra_args=()
	[[ ${VERIFY_SIG_OPENPGP_KEY_REFRESH} == yes ]] || extra_args+=( -R )
	[[ -n ${VERIFY_SIG_OPENPGP_KEYSERVER+1} ]] && extra_args+=(
		--keyserver "${VERIFY_SIG_OPENPGP_KEYSERVER}"
	)

	# GPG upstream knows better than to follow the spec, so we can't
	# override this directory.  However, there is a clean fallback
	# to GNUPGHOME.
	addpredict /run/user

	local filename=${file##*/}
	[[ ${file} == - ]] && filename='(stdin)'
	einfo "Verifying ${filename} ..."
	gemato gpg-wrap -K "${key}" "${extra_args[@]}" -- \
		gpg --verify --output="${output_file}" "${file}" ||
		die "PGP signature verification failed"
}

# @FUNCTION: verify-all-sigs_verify_signed_checksums
# @USAGE: <checksum-file> <algo> <files> [<key-file>]
# @DESCRIPTION:
# Verify the checksums for all files listed in the space-separated list
# <files> (akin to ${A}) using a PGP-signed <checksum-file>.  <algo>
# specified the checksum algorithm (e.g. sha256).  <key-file> can either
# be passed directly, or it defaults to VERIFY_SIG_OPENPGP_KEY_PATH.
#
# The function dies if PGP verification fails, the checksum file
# contains unsigned data, one of the files do not match checksums
# or are missing from the checksum file.
verify-all-sigs_verify_signed_checksums() {
	local checksum_file=${1}
	local algo=${2}
	local files=()
	read -r -d '' -a files <<<"${3}"
	local key=${4:-${VERIFY_SIG_OPENPGP_KEY_PATH}}

	local chksum_prog chksum_len
	case ${algo} in
		sha256)
			chksum_prog=sha256sum
			chksum_len=64
			;;
		*)
			die "${FUNCNAME}: unknown checksum algo ${algo}"
			;;
	esac

	[[ -n ${key} ]] ||
		die "${FUNCNAME}: no key passed and VERIFY_SIG_OPENPGP_KEY_PATH unset"

	local checksum filename junk ret=0 count=0
	while read -r checksum filename junk; do
		[[ ${#checksum} -eq ${chksum_len} ]] || continue
		[[ -z ${checksum//[0-9a-f]} ]] || continue
		has "${filename}" "${files[@]}" || continue
		[[ -z ${junk} ]] || continue

		"${chksum_prog}" -c --strict - <<<"${checksum} ${filename}"
		if [[ ${?} -eq 0 ]]; then
			(( count++ ))
		else
			ret=1
		fi
	done < <(verify-all-sigs_verify_message "${checksum_file}" - "${key}")

	[[ ${ret} -eq 0 ]] ||
		die "${FUNCNAME}: at least one file did not verify successfully"
	[[ ${count} -eq ${#files[@]} ]] ||
		die "${FUNCNAME}: checksums for some of the specified files were missing"
}

# @FUNCTION: verify-all-sigs_verify-commit
# @USAGE: <git-directory> [<key-file>]
# @DESCRIPTION:
# Verifies the newest (HEAD) commit in the supplied directory
# using the supplied key file
verify-all-sigs_verify-commit() {
	local git_dir=${1}
	local key=${2:-${VERIFY_GIT_SIG_OPENPGP_KEY_PATH}}

	[[ -n ${key} ]] ||
		die "${FUNCNAME}: no key passed and VERIFY_GIT_SIG_OPENPGP_KEY_PATH unset"

	local extra_args=( "-R" )

	gemato gpg-wrap -K "${key}" "${extra_args[@]}" -- \
		git --work-tree="${git_dir}" --git-dir="${git_dir}"/.git verify-commit HEAD ||
		die "Git commit verification failed"
}

# for internal use only (from unpacker.eclass)
find_unpackable_file() {
	local src=$1
	if [[ -z ${src} ]] ; then
		src=${DISTDIR}/${A}
	else
		if [[ ${src} == ./* ]] ; then
			: # already what we want
		elif [[ -e ${DISTDIR}/${src} ]] ; then
			src=${DISTDIR}/${src}
		elif [[ -e ${PWD}/${src} ]] ; then
			src=${PWD}/${src}
		elif [[ -e ${src} ]] ; then
			src=${src}
		fi
	fi
	[[ ! -e ${src} ]] && return 1
	echo "${src}"
}

# @FUNCTION: verify-all-sigs_src_unpack
# @DESCRIPTION:
# Default src_unpack override that verifies signatures for all
# distfiles if 'verify-sig' flag is enabled __OR__ verifies git signature
# on top commit.  The function dies if any
# of the signatures fails to verify or if a distfile or top commit is not signed.
# Please write src_unpack() yourself if you need to perform partial
# verification.
verify-all-sigs_src_unpack() {
	if has "verify-git-sig" ${IUSE} ; then
		git-r3_src_unpack
		if use verify-git-sig ; then
			verify-all-sigs_verify-commit "${EGIT_CHECKOUT_DIR:-${WORKDIR}/${P}}"
		fi
	fi
	if use verify-sig; then
		local f suffix found
		local distfiles=() signatures=() nosigfound=() straysigs=()
		local files=()
		if has "verify-git-sig" ${IUSE} ; then
			local file
			while IFS= read -r -d '' file; do
				files+=( "${file}" )
			done < <(find "${S}" -not -path "${S}/.git/*" -not -path "${S}/.gitignore" -type f -print0)
		else
			for f in ${A}; do
				files+=( "${DISTDIR}/${f}" )
			done
		fi

		# find all distfiles and signatures, and combine them
		for f in ${files[@]}; do
			found=
			for suffix in .asc .sig; do
				if [[ ${f} == *${suffix} ]]; then
					signatures+=( "${f}" )
					found=sig
					break
				else
					if has "${f}${suffix}" ${files[@]}; then
						distfiles+=( "${f}" )
						found=dist+sig
						break
					fi
				fi
			done
			if [[ ! ${found} ]]; then
				nosigfound+=( "${f}" )
			fi
		done

		# check if all distfiles are signed
		if [[ ${#nosigfound[@]} -gt 0 ]]; then
			eerror "The following distfiles lack detached signatures:"
		 	for f in "${nosigfound[@]}"; do
		 		eerror "  ${f}"
		 	done
		 	die "Unsigned distfiles found"
		fi

		# check if there are no stray signatures
		for f in "${signatures[@]}"; do
			if ! has "${f%.*}" "${distfiles[@]}"; then
				straysigs+=( "${f}" )
			fi
		done
		if [[ ${#straysigs[@]} -gt 0 ]]; then
			eerror "The following signatures do not match any distfiles:"
			for f in "${straysigs[@]}"; do
				eerror "  ${f}"
			done
			die "Unused signatures found"
		fi

		# now perform the verification
		for f in "${signatures[@]}"; do
			verify-all-sigs_verify_detached \
				"${f%.*}" "${f}"
		done

		if ! has "verify-git-sig" ${IUSE}; then
			set -- ${A}
			for a ; do
				if [[ ${a} == *.asc || ${a} == *.sig ]]; then
					continue
				fi
				local m=$(echo "${a}" | tr '[:upper:]' '[:lower:]')
				a=$(find_unpackable_file "${a}")

				# figure out the decompression method
				local comp=""
				case ${m} in
				*.zst)
					comp="zstd -dfc" ;;
				esac

				# figure out if there are any archiving aspects
				local arch=""
				case ${m} in
				*.tgz|*.tbz|*.tbz2|*.txz|*.tar.*|*.tar)
					arch="tar --no-same-owner -xof" ;;
				esac

				# do the unpack
				if [[ -z ${arch}${comp} ]] ; then
					unpack "$1"
					return $?
				fi
				[[ ${arch} != unpack_* ]] && unpack_banner "${a}"
				if [[ -z ${arch} ]] ; then
					# Need to decompress the file into $PWD #408801
					local _a=${a%.*}
					${comp} "${a}" > "${_a##*/}"
				elif [[ -z ${comp} ]] ; then
					${arch} "${a}"
				else
					${comp} "${a}" | ${arch} -
				fi
				assert "unpacking ${a} failed (comp=${comp} arch=${arch})"
			done
		fi
	fi
}

_VERIFY_ALL_SIGS_ECLASS=1
fi

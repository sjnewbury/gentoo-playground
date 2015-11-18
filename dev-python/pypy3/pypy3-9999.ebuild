# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# pypy3 needs to be built using python 2
PYTHON_COMPAT=( python2_7 pypy )
inherit check-reqs eutils multilib multiprocessing pax-utils \
	python-any-r1 toolchain-funcs versionator mercurial

DESCRIPTION="A fast, compliant alternative implementation of Python 3"
HOMEPAGE="http://pypy.org/"
#SRC_URI="https://bitbucket.org/pypy/pypy/downloads/${P}-src.tar.bz2"
EHG_REPO_URI=https://bitbucket.org/pypy/pypy
EHG_REVISION=py3k

LICENSE="MIT"
SLOT="0/$(get_version_component_range 1-2 ${PV})"
KEYWORDS=""
IUSE="bzip2 doc gdbm +jit low-memory ncurses sandbox shadowstack sqlite cpu_flags_x86_sse2 test tk"

RDEPEND=">=sys-libs/zlib-1.1.3:0=
	virtual/libffi:0=
	virtual/libintl:0=
	dev-libs/expat:0=
	dev-libs/openssl:0=[-bindist]
	bzip2? ( app-arch/bzip2:0= )
	gdbm? ( sys-libs/gdbm:0= )
	ncurses? ( sys-libs/ncurses:0= )
	sqlite? ( dev-db/sqlite:3= )
	tk? (
		dev-lang/tk:0=
		dev-tcltk/tix:0=
	)
	!dev-python/pypy-bin:0"
DEPEND="${RDEPEND}
	doc? ( dev-python/sphinx )
	${PYTHON_DEPS}
	test? ( dev-python/pytest )"
PDEPEND="app-admin/python-updater"

S="${WORKDIR}/${P}-src"

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		if use low-memory; then
			if ! python_is_installed pypy; then
				eerror "USE=low-memory requires a (possibly old) version of dev-python/pypy"
				eerror "or dev-python/pypy-bin being installed. Please install it using e.g.:"
				eerror
				eerror "  $ emerge -1v dev-python/pypy-bin"
				eerror
				eerror "before attempting to build dev-python/pypy[low-memory]."
				die "dev-python/pypy-bin (or dev-python/pypy) needs to be installed for USE=low-memory"
			fi

			CHECKREQS_MEMORY="1750M"
			use amd64 && CHECKREQS_MEMORY="3500M"
		else
			CHECKREQS_MEMORY="3G"
			use amd64 && CHECKREQS_MEMORY="6G"
		fi

		check-reqs_pkg_pretend
	fi
}

pkg_setup() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		pkg_pretend

		if python_is_installed pypy; then
			if [[ ! ${EPYTHON} || ${EPYTHON} == pypy ]] || use low-memory; then
				einfo "Using already-installed PyPy to perform the translation."
				local EPYTHON=pypy
			else
				einfo "Using ${EPYTHON} to perform the translation. Please note that upstream"
				einfo "recommends using PyPy for that. If you wish to do so, please unset"
				einfo "the EPYTHON variable."
			fi
		fi

		python-any-r1_pkg_setup
	fi
}

src_prepare() {
	epatch "${FILESDIR}/1.9-scripts-location.patch"
 	epatch "${FILESDIR}/1.9-distutils.unixccompiler.UnixCCompiler.runtime_library_dir_option.patch"
 	epatch "${FILESDIR}"/${PV}-shared-lib.patch	# 517002

	epatch_user
}

src_compile() {
	tc-export CC

	local jit_backend
	if use jit; then
		jit_backend='--jit-backend='

		# We only need the explicit sse2 switch for x86.
		# On other arches we can rely on autodetection which uses
		# compiler macros. Plus, --jit-backend= doesn't accept all
		# the modern values...

		if use x86; then
			if use cpu_flags_x86_sse2; then
				jit_backend+=x86
			else
				jit_backend+=x86-without-sse2
			fi
		else
			jit_backend+=auto
		fi
	fi

	local args=(
		--shared
		$(usex jit -Ojit -O2)
		$(usex shadowstack --gcrootfinder=shadowstack '')
		$(usex sandbox --sandbox '')

		${jit_backend}
		--make-jobs=$(makeopts_jobs)

		pypy/goal/targetpypystandalone
	)

	# Avoid linking against libraries disabled by use flags
	local opts=(
		bzip2:bz2
		ncurses:_minimal_curses
	)

	local opt
	for opt in "${opts[@]}"; do
		local flag=${opt%:*}
		local mod=${opt#*:}

		args+=(
			$(usex ${flag} --withmod --withoutmod)-${mod}
		)
	done

	local interp=( "${PYTHON}" )
	if use low-memory; then
		interp=( env PYPY_GC_MAX_DELTA=200MB
			"${PYTHON}" --jit loop_longevity=300 )
	fi

	set -- "${interp[@]}" rpython/bin/rpython --batch "${args[@]}"
	echo -e "\033[1m${@}\033[0m"
	"${@}" || die "compile error"

	use doc && emake -C pypy/doc/ html
	pax-mark m "${ED%/}${INSDESTTREE}/pypy-c"
}

src_test() {
	# (unset)
	local -x PYTHONDONTWRITEBYTECODE

	# Test runner requires Python 2 too. However, it spawns PyPy3
	# internally so that we end up testing the correct interpreter.
	"${PYTHON}" ./pypy/test_all.py --pypy=./pypy-c lib-python || die
}

src_install() {
	einfo "Installing PyPy ..."
	insinto "/usr/$(get_libdir)/pypy3"
	doins -r include lib_pypy lib-python pypy-c libpypy-c.so
	fperms a+x ${INSDESTTREE}/pypy-c ${INSDESTTREE}/libpypy-c.so
	pax-mark m "${ED%/}${INSDESTTREE}/pypy-c" "${ED%/}${INSDESTTREE}/libpypy-c.so"
	dosym ../$(get_libdir)/pypy3/pypy-c /usr/bin/pypy3
	dodoc README.rst

	if ! use gdbm; then
		rm -r "${ED%/}${INSDESTTREE}"/lib_pypy/gdbm.py \
			"${ED%/}${INSDESTTREE}"/lib-python/*3/test/test_gdbm.py || die
	fi
	if ! use sqlite; then
		rm -r "${ED%/}${INSDESTTREE}"/lib-python/*3/sqlite3 \
			"${ED%/}${INSDESTTREE}"/lib_pypy/_sqlite3.py \
			"${ED%/}${INSDESTTREE}"/lib-python/*3/test/test_sqlite.py || die
	fi
	if ! use tk; then
		rm -r "${ED%/}${INSDESTTREE}"/lib-python/*3/{idlelib,lib-tk} \
			"${ED%/}${INSDESTTREE}"/lib_pypy/_tkinter \
			"${ED%/}${INSDESTTREE}"/lib-python/*3/test/test_{tcl,tk,ttk*}.py || die
	fi

	# Install docs
	use doc && dohtml -r pypy/doc/_build/html/

	einfo "Generating caches and byte-compiling ..."

	python_export pypy3 EPYTHON PYTHON PYTHON_SITEDIR
	local PYTHON=${ED%/}${INSDESTTREE}/pypy-c
	local -x LD_LIBRARY_PATH="${ED%/}${INSDESTTREE}"

	echo "EPYTHON='${EPYTHON}'" > epython.py
	python_domodule epython.py

	# Generate Grammar and PatternGrammar pickles.
	"${PYTHON}" -c "import lib2to3.pygram, lib2to3.patcomp; lib2to3.patcomp.PatternCompiler()" \
		|| die "Generation of Grammar and PatternGrammar pickles failed"

	# Generate cffi modules
	# Please keep in sync with pypy/tool/release/package.py!
#cffi_build_scripts = {
#    "sqlite3": "_sqlite3_build.py",
#    "audioop": "_audioop_build.py",
#    "tk": "_tkinter/tklib_build.py",
#    "curses": "_curses_build.py" if sys.platform != "win32" else None,
#    "syslog": "_syslog_build.py" if sys.platform != "win32" else None,
#    "gdbm": "_gdbm_build.py"  if sys.platform != "win32" else None,
#    "pwdgrp": "_pwdgrp_build.py" if sys.platform != "win32" else None,
	cffi_targets=( audioop syslog pwdgrp )
	use gdbm && cffi_targets+=( gdbm )
	use ncurses && cffi_targets+=( curses )
	use sqlite && cffi_targets+=( sqlite3 )
	use tk && cffi_targets+=( tkinter/tklib )

	local t
	# all modules except tkinter output to .
	# tkinter outputs to the correct dir ...
	cd "${ED%/}${INSDESTTREE}"/lib_pypy || die
	for t in "${cffi_targets[@]}"; do
		# tkinter doesn't work via -m
		"${PYTHON}" "_${t}_build.py" || die "Failed to build CFFI bindings for ${t}"
	done

	# Cleanup temporary objects
	find "${ED%/}${INSDESTTREE}" -name "_cffi_*.[co]" -delete || die
	find "${ED%/}${INSDESTTREE}" -type d -empty -delete || die

	# compile the installed modules
	python_optimize "${ED%/}${INSDESTTREE}"
}

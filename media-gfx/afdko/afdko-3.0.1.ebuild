EAPI="6"

PYTHON_COMPAT=( python3_{7,8,9,10} )

inherit distutils-r1

DESCRIPTION="Adobe Font Development Kit for OpenType"
HOMEPAGE="http://www.adobe.com/devnet/opentype/afdko.html"
SRC_URI="https://github.com/adobe-type-tools/${PN}/releases/download/${PV}/${P}.tar.gz"

LICENSE="AFDKL"
SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="
	>=dev-python/ufoProcessor-1.0.6[${PYTHON_USEDEP}]
	>=dev-python/ufoNormalizer-0.3.6[${PYTHON_USEDEP}]
	>=dev-util/psautohint-2.0.0_alpha1[${PYTHON_USEDEP}]
	>=dev-python/MutatorMath-2.1.2[${PYTHON_USEDEP}]
	>=dev-python/fonttools-4.0.0[unicode,ufo,${PYTHON_USEDEP}]
	>=dev-python/cu2qu-1.6.5[${PYTHON_USEDEP}]
	>=dev-python/py-zopfli-0.1.4[${PYTHON_USEDEP}]
	>=dev-python/fontPens-0.2.4[${PYTHON_USEDEP}]
"

src_prepare() {
	default
	sed -i \
		-e 's/==/>=/' \
		python/afdko.egg-info/requires.txt \
		requirements.txt || die ufoProcessor version bump
}

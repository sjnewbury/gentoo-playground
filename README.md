gentoo-playground
=================
This repository contains ebuilds which fall into the following categories:

* ebuilds modified from those in portage for supporting
  additional features (usually with new USE flags)

* version bumped higher than those yet in the portage tree

* fixed ebuilds for updated dependencies or where there is
  bug in the portage version which hasn't yet been fixed

* all new packages not currently in portage


<h2>New ebuilds</h2>

There are many new ebuilds for packages that are not in
Portage, many of them are "live", this includes for example,
app-i18n/libphonenumber, as required for syncevolution to
build with dbus-pim support.  If anybody wants a stable version
of any of these ebuilds, let me know.  Also feel free to open
Gentoo bugzilla entries for new ebuilds from this repository,
just do please drop me a note.

<h2>libretro</h2>

Currently there are some RetroArch/libretro ebuilds included
which are fixed/tweaked versions of ebuilds from abendbrot's
overlay.  I haven't provided any ebuilds I haven't modified,
so if you want to use libretro/RetroArch I recommend adding
abendbrot's overlay. 


<b>WARNING! WARNING!</b> Some ebuilds in this repo supercede those in Portage
and have KEYWORDS copied from their Portage counterparts.  Until I rectify
this or alternatively provide a local mask in this repo, I recommend
adding a local mask for */*::gentoo-playground, then unmasking specific
packages as needed.

I would accept pull requests to rectify this situation.

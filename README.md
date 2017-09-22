Pulsar Library Base Repository
==============================

The purpose of this repository is to store a crisp, clean version of the CMake
build infastructure that is common to many of the Pulsar libraries.  If you are
building a library that is meant to provide core Pulsar functionality or if it
is just meant to be a module for Pulsar it is strongly recommended you use this
repository to save you a lot of headaches in putting together a build.

For the purposes of this guide we assume you are making a repository named
"MyRepo", the name of which is case sensitive.  `PulsarLibraryBase` will then
put together the CMake infrastructure required to make a library named
`libMyRepo.so` (TODO: Other extensions and static libraries). MyRepo's library,
as well as all of its public header files and the libraries/includes of all of
its dependencies, will be locatable find CMake's `find_package` mechanism via
an automatically generated file: `MyRepoConfig.cmake`.

`PulsarLibraryBase` works off of git-subrepo
[GitHub repo](https://github.com/ingydotnet/git-subrepo).  This is an
extension of git that (arguably) implements submodules/subtrees correctly. You
will need git-subrepo to add `PulsarLibraryBase` to MyRepo as a subrepo.  Users
of MyRepo will not need git-subrepo to use MyRepo, nor will developers need
git-subrepo to extend MyRepo (the exception being if you need to update the
commit of `PulsarLibraryBase` used by MyRepo, then you'll need git-subrepo).


How To Use
----------

0. "Install" git subrepo if you haven't already (it's just a bash script)
1. In the top-level directory of your project run:
   ```git
   git subrepo clone https://github.com/pulsar-chem/PulsarLibraryBase
   ```
2. Run: `PulsarLibraryBase/bin/BasicSetup.sh <MyRepo>`
3. Add your dependencies to `CMakeLists.txt`
4. Fill in the source files and public headers of your library in `MyRepo/CMakeLists.txt`
5. Add your tests to `MyRepo/CMakeLists.txt`

Results
=======

If you use this repo as described above the result will be a CMake superbuild
of one main target called `MyRepo`.  A `MyRepoConfig.cmake` CMake configuration
file will be generated for you from your build settings.  Finally, it will all
be installed as:

:file_folder: CMAKE_INSTALL_PREFIX  
├──:file_folder: include  
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└──:file_folder: MyRepo  
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└──:page_facing_up: MyHeaderFile.hpp  
├──:file_folder: lib  
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└──:file_folder: MyRepo  
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└──:books: libMyRepo.so  
└──:file_folder: share  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└──:file_folder: cmake  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└──:file_folder: MyRepo  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└──:page_facing_up: MyRepoConfig.cmake

Furthermore because `PulsarLibraryBase` takes care of 99.9% of the build for
you, we went ahead and wrote your build documentation for you.  Just include
`dox/Building.md` in your documentation and take all the credit for some of the
best build documentation around.

Assumptions
===========

This setup assumes you are building a library and that you will want to install
that library. It furthermore assumes your repository is laid out as follows:

:file_folder: root  
├──:file_folder: PulsarLibraryBase  
├──:file_folder: MyRepo  
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└──:page_facing_up: CMakeLists.txt  
├──:file_folder: MyRepo_Test  
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└──:page_facing_up: CMakeLists.txt  
└──:page_facing_up: CMakeLists.txt  

Aside from that, the layout of your repository is somewhat arbitrary as long as
you set the variables described above correctly and use the provided macros.
That said, because this is a subrepo you are free to modify any of the CMake
infrastructure provided by `PulsarLibraryBase`. To do so, simply modify the
files and then commit them to **your** repo (this will happen by default, you
actually have to go out of your way to commit them to the `PulsarLibraryBase`
repo; that said, if your modifications are general, consider contributing them
back).  At any point if `PulsarLibraryBase` is updated you simply need to run:
```git
git subrepo pull PulsarLibraryBase
```
and git will esentially rebase your changes on top of the updated subrepo (that
is it will pull the current head of `PulsarLibraryBase` and then replay your
changes on top of it).  If conflicts emerge you'll have to resolve them
manually, there's just nothing we can do for you there.

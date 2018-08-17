# Changelog

## Master

##### Enhancements

* None.  

##### Bug Fixes

* Allow flattening nested archives where a directory has the same name as the 
  directory to be flattened.  
  [Samuel Giddins](https://github.com/segiddins)


## 1.2.1 (2018-05-25)

##### Enhancements

* Allow `curl` to retry HTTP downloads that fail with transient errors.  
  [Samuel Giddins](https://github.com/segiddins)

##### Bug Fixes

* Remove archives after an `HTTP` download.  
  [Samuel Giddins](https://github.com/segiddins)

## 1.2.0 (2018-04-04)

##### Enhancements

* Added support for SCP.  
  [Ryosuke Ito](https://github.com/manicmaniac)

##### Bug Fixes

* None.  


## 1.1.3 (2016-12-17)

##### Enhancements

* Add support for servers that don't support shallow clones on git >= 2.11.x  
  [Danielle Tomlinson](https://github.com/dantoml)
  [#6270](https://github.com/CocoaPods/CocoaPods/issues/6270)

##### Bug Fixes

* None.  


## 1.1.2 (2016-10-19)

##### Enhancements

* None.  

##### Bug Fixes

* Use `git -C` rather than `chdir`.  
  [Danielle Tomlinson](https://github.com/dantoml)
  [#62](https://github.com/CocoaPods/cocoapods-downloader/pull/62)


## 1.1.1 (2016-08-30)

##### Enhancements

* None.  

##### Bug Fixes

* Ensure submodules are updated after checking out a specific git commit.  
  [Samuel Giddins](https://github.com/segiddins)
  [CocoaPods#5778](https://github.com/CocoaPods/CocoaPods/issues/5778)


## 1.1.0 (2016-07-11)

##### Enhancements

* When downloading via `HTTP`, `curl` won't force users from having a
  `~/.netrc` file set up on their machine when the remote server requires
  authentication.  
  [Sylvain Guillopé](https://github.com/sguillope)
  [#55](https://github.com/CocoaPods/cocoapods-downloader/issues/55)
  [CocoaPods#5318](https://github.com/CocoaPods/CocoaPods/issues/5318)

* Allow download strategies to preprocess download options. This is used by
  `git` strategy to resolve branches into commits directly.  
  [Juan Civile](https://github.com/champo)
  [CocoaPods#5386](https://github.com/CocoaPods/CocoaPods/pull/5386)


## 1.0.1 (2016-06-24)

##### Enhancements

* None.  

##### Bug Fixes

* When downloading git submodules, use an explicit command (`git submodules
  --init --recursive`) instead of relying on the `--recursive` behavior for
  `git checkout`. This fixes an issue where submodules were checked out using
  `--depth=1` under git 2.9.  
  [Gordon Fontenot](https://github.com/gfontenot)
  [#58](https://github.com/CocoaPods/cocoapods-downloader/pull/58)
  [CocoaPods#5555](https://github.com/CocoaPods/CocoaPods/issues/5555)


## 1.0.0 (2016-05-10)

##### Enhancements

* None.  

##### Bug Fixes

* None.  


## 1.0.0.rc.1 (2016-04-30)

##### Enhancements

* None.  

##### Bug Fixes

* None.  


## 1.0.0.beta.3 (2016-04-14)

##### Enhancements

* When downloading via `HTTP`, `curl` will take into account the user's
  `~/.netrc` file to determine authentication credentials.  
  [Marius Rackwitz](https://github.com/mrackwitz)
  [#53](https://github.com/CocoaPods/cocoapods-downloader/issues/53)
  [CocoaPods#5055](https://github.com/CocoaPods/CocoaPods/issues/5055)

##### Bug Fixes

* None.  


## 1.0.0.beta.2 (2016-03-15)

##### Bug Fixes

* Perform git clones without copying the user's default git repo templates.  
  [Samuel Giddins](https://github.com/segiddins)
  [CocoaPods#4715](https://github.com/CocoaPods/CocoaPods/issues/4715)


## 1.0.0.beta.1 (2015-12-30)

##### Enhancements

+ Support for Apple disk images (`.dmg` files) in the HTTP downloader.  
  [Ryosuke Ito](https://github.com/manicmaniac)

##### Bug Fixes

* Include the `submodules` option in the git checkout options when it is
  specified.  
  [Samuel Giddins](https://github.com/segiddins)
  [CocoaPods#3421](https://github.com/CocoaPods/CocoaPods/issues/3421)


## 0.9.3 (2015-08-28)

##### Bug Fixes

* This release fixes a file permissions error when using the RubyGem.  
  [Samuel Giddins](https://github.com/segiddins)


## 0.9.2 (2015-08-26)

##### Bug Fixes

* Checkout git submodules recursively.  
  [Boris Bügling](https://github.com/neonichu)
  [Samuel Giddins](https://github.com/segiddins)
  [#46](https://github.com/CocoaPods/cocoapods-downloader/pull/46)


## 0.9.1 (2015-06-27)

##### Enhancements

* Don't checkout git commits onto a new branch, just use the detached head.  
  [Samuel Giddins](https://github.com/segiddins)


## 0.9.0 (2015-04-01)

##### Enhancements

* Execute downloads without the use of a subshell (or ensuring that all command
  arguments are escaped).  
  [Samuel Giddins](https://github.com/segiddins)


## 0.8.1 (2014-12-25)

##### Bug Fixes

* Ensure that `curl` fails on HTTP error status codes so that archive handling
  fails at the right time and not when it tries to unpack a 404 HTML document.
  [Eloy Durán](https://github.com/alloy)
  [#41](https://github.com/CocoaPods/cocoapods-downloader/issues/41)


## 0.8.0 (2014-11-15)

##### Breaking

* Support for older versions of Ruby has been dropped. cocoapods-downloader now
  requires Ruby 2.0.0 or greater.
  [Kyle Fuller](https://github.com/kylef)

##### Bug Fixes

* Fixes an issue detecting file types when query parameters are used.  
  [Michael Bishop](https://github.com/mbishop-fiksu)
  [#40](https://github.com/CocoaPods/cocoapods-downloader/pull/40)


## 0.7.2 (2014-10-07)

###### Enhancements

* Fixed fetching from 'dumb' git remotes that don't support shallow clones.  
  [Samuel Giddins](https://github.com/segiddins)
  [CocoaPods#2537](https://github.com/CocoaPods/CocoaPods/issues/2537)
  [#35](https://github.com/CocoaPods/cocoapods-downloader/issues/35)


## 0.7.1 (2014-09-26)

###### Bug Fixes

* Fixed an issue downloading shallow git submodules.  
  [Richard Lee](https://github.com/dlackty)
  [#32](https://github.com/CocoaPods/cocoapods-downloader/issues/32)

## 0.7.0 (2014-09-11)

###### Breaking

* The `Git` cache and the `GitHub` strategy have been dropped.  
  [Fabio Pelosin](https://github.com/fabiopelosin)

###### Enhancements

* Improved performance of `Git` downloads using shallow clone.  
  [Marin Usalj](https://github.com/supermarin)
  [Fabio Pelosin](https://github.com/fabiopelosin)

* Added method to check if the head strategy is supported by a concreted
  downloader class.  
  [Fabio Pelosin](https://github.com/fabiopelosin)
  [#12](https://github.com/CocoaPods/cocoapods-downloader/issues/12)

###### Bug Fixes

* Fixed the check for git references on Ruby 1.8.7.  
  [Fabio Pelosin](https://github.com/fabiopelosin)
  [#28](https://github.com/CocoaPods/cocoapods-downloader/issues/28)


## 0.6.1 (2014-05-20)

* Robustness against string keys.  
  [Fabio Pelosin](https://github.com/fabiopelosin)
  [#25](https://github.com/CocoaPods/cocoapods-downloader/issues/25)

## 0.6.0 (2014-05-19)

###### Enhancements

* Added support for `:checkout` option in SVN sources.  
  [Marc C.](https://github.com/yalp)
  [Fabio Pelosin](https://github.com/fabiopelosin)
  [#7](https://github.com/CocoaPods/cocoapods-downloader/pull/7)

* Added support for `:sha1` and `:sha256` options in HTTP sources to verify a
  files checksum.  
  [Kyle Fuller](https://github.com/kylef)
  [CocoaPods#2105](https://github.com/CocoaPods/CocoaPods/issues/2105)

## 0.5.0 (2014-04-15)

###### Enhancements

* Added support for `:tag` option in mercurial sources.  
  [Esteban Bouza](https://github.com/estebanbouza)
  [#16](https://github.com/CocoaPods/cocoapods-downloader/issues/16)

* Added support for `:branch` option in mercurial sources.  
  [Esteban Bouza](https://github.com/estebanbouza)
  [#17](https://github.com/CocoaPods/cocoapods-downloader/issues/17)

###### Bug Fixes

* Support `:http` downloads with `get` parameters.  
  [Fabio Pelosin](https://github.com/fabiopelosin)
  [#15](https://github.com/CocoaPods/cocoapods-downloader/issues/15)

## 0.4.1 (2014-03-31)

* add shellescape for some path arguments in git.rb
  [Vladimir Burdukov](https://github.com/chipp)
  [#14](https://github.com/CocoaPods/cocoapods-downloader/pull/14)

## 0.4.0 (2014-03-26)

###### Enhancements

* Added support to ignore externals (--ignore-externals command line flag) for
  SVN sources. To ignore the externals it is necessary to specify the
  `:externals => false` option.  
  [banjun](https://github.com/banjun)
  [#8](https://github.com/CocoaPods/cocoapods-downloader/pull/8)

* Shell-escape all paths to be more robust against spaces/quotes in paths.  
  [Mike Walker](https://github.com/lazerwalker)
  [#6](https://github.com/CocoaPods/cocoapods-downloader/pull/6)

## 0.3.0 (2013-12-24)

###### Enhancements

* Support LZMA2 compressed tarballs in the  
  [Kyle Fuller](https://github.com/kylef)
  [#5](https://github.com/CocoaPods/cocoapods-downloader/pull/5)


## 0.2.0 (2013-09-04)

###### Enhancements

* Added support for Bazaar repositories.  
  [Fred McCann](https://github.com/fmccann)
  [#4](https://github.com/CocoaPods/cocoapods-downloader/pull/4)


## 0.1.2 (2013-08-02)

###### Enhancements

* Improved performance of sources which specify a tag.  
  [CocoaPods/CocoaPods#1077](https://github.com/CocoaPods/CocoaPods/issues/1077)

* Added support for specification of the cache path relative from the current
  working directory.  
  [#1](https://github.com/CocoaPods/cocoapods-downloader/issues/1)

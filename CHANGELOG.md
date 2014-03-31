# Changelog

## Master

## 0.4.1

* add shellescape for some path arguments in git.rb
  [Vladimir Burdukov](https://github.com/chipp)
  [#14](https://github.com/CocoaPods/cocoapods-downloader/pull/14)

## 0.4.0

###### Enhancements

* Added support to ignore externals (--ignore-externals command line flag) for
  SVN sources. To ignore the externals it is necessary to specify the
  `:externals => false` option.  
  [banjun](https://github.com/banjun)
  [#8](https://github.com/CocoaPods/cocoapods-downloader/pull/8)

* Shell-escape all paths to be more robust against spaces/quotes in paths.  
  [Mike Walker](https://github.com/lazerwalker)
  [#6](https://github.com/CocoaPods/cocoapods-downloader/pull/6)

## 0.3.0

###### Enhancements

* Support LZMA2 compressed tarballs in the  
  [Kyle Fuller](https://github.com/kylef)
  [#5](https://github.com/CocoaPods/cocoapods-downloader/pull/5)


## 0.2.0

###### Enhancements

* Added support for Bazaar repositories.  
  [Fred McCann](https://github.com/fmccann)
  [#4](https://github.com/CocoaPods/cocoapods-downloader/pull/4)


## 0.1.2

###### Enhancements

* Improved performance of sources which specify a tag.  
  [CocoaPods/CocoaPods#1077](https://github.com/CocoaPods/CocoaPods/issues/1077)

* Added support for specification of the cache path relative from the current
  working directory.  
  [#1](https://github.com/CocoaPods/cocoapods-downloader/issues/1)


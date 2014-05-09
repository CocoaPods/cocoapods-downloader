$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'cocoapods-downloader'

path = ''
options = {}
downloader = Pod::Downloader.for_target(path, options)
downloader.cache_root = ''
downloader.max_cache_size = 500
downloader.download

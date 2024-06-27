# -*- encoding: utf-8 -*-
$:.unshift File.expand_path('../lib', __FILE__)
require 'cocoapods-downloader/gem_version'

Gem::Specification.new do |s|
  s.name     = "cocoapods-downloader"
  s.version  = Pod::Downloader::VERSION
  s.license  = "MIT"
  s.email    = ["eloy.de.enige@gmail.com", "fabiopelosin@gmail.com"]
  s.homepage = "https://github.com/CocoaPods/cocoapods-downloader"
  s.authors  = ["Eloy Duran", "Fabio Pelosin"]

  s.summary  = "A small library for downloading files from remotes in a folder."

  s.files = Dir["lib/**/*.rb"] + %w{ README.markdown LICENSE }
  s.require_paths = %w{ lib }

  s.required_ruby_version = '>= 2.6'
  s.specification_version = 3 if s.respond_to? :specification_version

  s.add_runtime_dependency 'zstd-ruby', '~> 1.5'
end

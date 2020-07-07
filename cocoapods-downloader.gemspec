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

  ## Make sure you can build the gem on older versions of RubyGems too:
  s.rubygems_version = "1.6.2"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>= 2.3.3'
  s.specification_version = 3 if s.respond_to? :specification_version
end

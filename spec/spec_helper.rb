require 'bacon'
require 'mocha-on-bacon'
require 'pathname'
require 'vcr'

$:.unshift File.expand_path('../../lib', __FILE__)
require 'cocoapods-downloader'
require File.expand_path('../spec_helper/bacon', __FILE__)

module Pod
  module Downloader
    class Base

      # Override hook to suppress executables output.
      #
      def execute_command(executable, command, raise_on_failure = false)
        output = `\n#{executable} #{command} 2>&1`
        check_exit_code!(executable, command, output) if raise_on_failure
        output
      end

      def download_action(ui_message) yield end
      def ui_sub_action(message) yield end
      def ui_message(message) end
    end
  end
end

def tmp_folder(path = '')
  return Pathname.pwd + 'tmp' + path
end

def fixture(path)
  return Pathname.pwd + 'spec/fixtures/' + path
end


# TODO is this still needed?
# require 'vcr'
# require 'webmock'
#
# VCR.configure do |c|
#   # Namespace the fixture by the Ruby version, because different Ruby versions
#   # can lead to different ways the data is interpreted.
#   c.cassette_library_dir = (ROOT + "spec/fixtures/vcr/#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}").to_s
#   c.hook_into :webmock # or :fakeweb
#   c.allow_http_connections_when_no_cassette = true
# end

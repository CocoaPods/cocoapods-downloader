# Set up coverage analysis
#-----------------------------------------------------------------------------#

if ENV['CI'] || ENV['GENERATE_COVERAGE']
  require 'simplecov'
  require 'coveralls'

  if ENV['CI']
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  elsif ENV['GENERATE_COVERAGE']
    SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
  end
  SimpleCov.start do
    add_filter "/spec_helper/"
  end
end

# Set up
#-----------------------------------------------------------------------------#

require 'bacon'
require 'mocha-on-bacon'
require 'pathname'

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

      def ui_action(ui_message)  yield end
      def ui_sub_action(message) yield end
      def ui_message(message)    end
    end
  end
end

def tmp_folder(path = '')
  return Pathname.pwd + 'tmp' + path
end

def tmp_folder_with_quotes(path = '')
  return tmp_folder File.join("a' \"b", path)
end

def fixture(path)
  return Pathname.pwd + 'spec/fixtures/' + path
end


require 'vcr'
require 'webmock'

VCR.configure do |c|
  # Namespace the fixture by the Ruby version, because different Ruby versions
  # can lead to different ways the data is interpreted.
  # TODO is this still needed?
  # c.cassette_library_dir = (ROOT + "spec/fixtures/vcr/#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}").to_s

  c.cassette_library_dir = (Pathname.pwd + "spec/fixtures/vcr").to_s
  c.hook_into :webmock
  # c.allow_http_connections_when_no_cassette = true
end

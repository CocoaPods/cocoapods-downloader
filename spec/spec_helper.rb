
#-- Set up coverage analysis -------------------------------------------------#

require 'codeclimate-test-reporter'

CodeClimate::TestReporter.configure do |config|
  config.logger.level = Logger::WARN
end

CodeClimate::TestReporter.start

#-- Requirements -------------------------------------------------------------#

require 'bacon'
require 'mocha-on-bacon'
require 'pathname'
require 'pretty_bacon'
require 'vcr'
require 'webmock'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'cocoapods-downloader'

#-- Output suppression -------------------------------------------------------#

module Pod
  module Downloader
    class Base
      # Override hook to suppress executables output.
      #
      def execute_command(executable, command, raise_on_failure = false)
        require 'shellwords'
        command = command.map(&:to_s).map(&:shellescape).join(' ')
        output = `\n#{executable} #{command} 2>&1`
        check_exit_code!(executable, command, output) if raise_on_failure
        output
      end

      def ui_action(_)
        yield
      end

      def ui_sub_action(_)
        yield
      end

      def ui_message(_)
      end
    end
  end
end

#-- Helpers ------------------------------------------------------------------#

def tmp_folder(path = '')
  Pathname.pwd + 'tmp' + path
end

def tmp_folder_with_quotes(path = '')
  tmp_folder File.join("a' \"b", path)
end

def fixture(path)
  Pathname.pwd + 'spec/fixtures/' + path
end

#-- VCR configuration --------------------------------------------------------#

VCR.configure do |c|
  c.cassette_library_dir = (Pathname.pwd + 'spec/fixtures/vcr').to_s
  c.hook_into :webmock
  c.ignore_hosts 'codeclimate.com'
end

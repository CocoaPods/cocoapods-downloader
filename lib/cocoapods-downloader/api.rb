module Pod
  module Downloader

    # The Downloader::Hooks module allows to adapt the Downloader to
    # the UI of other gems.
    #
    module API

      def check_exit_code!(executable, command, output)
        if $?.to_i != 0
          raise DownloaderError, "Error on `#{executable} #{command}`.\n#{output}"
        end
      end

      def execute_command(executable, command, raise_on_failure = false)
        output = `\n#{executable} #{command} 2>&1`
        check_exit_code!(executable, command, output) if raise_on_failure
        puts output
        output
      end

      def download_action(ui_message)
        puts "\n#{ui_message}"
        yield
      end
    end
  end
end

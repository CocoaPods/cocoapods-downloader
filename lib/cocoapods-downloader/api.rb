module Pod
  module Downloader

    # The Downloader::Hooks module allows to adapt the Downloader to
    # the UI of other gems.
    #
    module API

      # Executes
      # @return [String] the ouptu of the command.
      #
      def execute_command(executable, command, raise_on_failure = false)
        output = `\n#{executable} #{command} 2>&1`
        check_exit_code!(executable, command, output) if raise_on_failure
        puts output
        output
      end

      # Cheks if the just executed command completed sucessfully.
      #
      # @raise  If the command failed.
      #
      # @return [void]
      #
      def check_exit_code!(executable, command, output)
        if $?.to_i != 0
          raise DownloaderError, "Error on `#{executable} #{command}`.\n#{output}"
        end
      end

      # Indicates that an action will be perfomed. The action is passed as a
      # block.
      #
      # @param  [String] message
      #         The message associated with the action.
      #
      # @yield  The action, this block is always exectued.
      #
      # @retur [void]
      #
      def ui_action(message)
        puts message
        yield
      end

      # Indicates that a minor action will be perfomed. The action is passed as
      # a block.
      #
      # @param  [String] message
      #         The message associated with the action.
      #
      # @yield  The action, this block is always exectued.
      #
      # @retur [void]
      #
      def ui_sub_action(message)
        puts message
        yield
      end

      # Prints an UI message.
      #
      # @param  [String] message
      #         The message associated with the action.
      #
      # @retur [void]
      #
      def ui_message(ui_message)
        puts message
      end
    end
  end
end

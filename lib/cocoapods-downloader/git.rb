module Pod
  module Downloader
    # Concreted Downloader class that provides support for specifications with
    # git sources.
    #
    class Git < Base
      def self.options
        [:commit, :tag, :branch, :submodules]
      end

      def options_specific?
        !(options[:commit] || options[:tag]).nil?
      end

      def checkout_options
        Dir.chdir(target_path) do
          options = {}
          options[:git] = url
          options[:commit] = `git rev-parse HEAD`.chomp
          options
        end
      end

      private

      executable :git

      def download!
        if options[:tag]
          download_tag
        elsif options[:branch]
          download_branch
        elsif options[:commit]
          download_commit
        else
          download_head!
        end
        Dir.chdir(target_path) { git! 'submodule update --init'  } if options[:submodules]
      end

      # @return [void] Checks out the HEAD of the git source in the destination
      #         path.
      #
      def download_head!
        clone(url, target_path)
        Dir.chdir(target_path) { git! 'submodule update --init'  } if options[:submodules]
      end

      #--------------------------------------#

      # @!group Download implementations

      # @return [void] Convenience method to perform clones operations.
      #
      # @todo Refactor / clean up this a bit later
      #
      def clone(from, to, flags = '')
        ui_sub_action('Cloning to Pods folder') do
          command = "clone #{from.shellescape} #{to.shellescape}"
          command << shallow_flags unless options[:commit]
          command << ' ' + flags if flags
          git!(command)
        end
      end

      # @return [void] Checks out a specific commit of the git source in the
      #         destination path.
      #
      # @note   Checks out output to standard error and thus it is
      #         redirected to stdout.
      #
      def download_commit
        clone(url, target_path)
        Dir.chdir(target_path) do
          git! "checkout -b activated-pod-commit #{options[:commit]} 2>&1"
        end
      end

      # @return [void] Checks out the HEAD of a specific branch of the git
      #         source in the destination path.
      #
      # @note   `git checkout` outputs to stderr and thus it is
      #         redirected to stdout.
      #
      def download_branch
        clone(url, target_path)
      end

      # @return [void] Checks out a specific tag of the git source in the
      #         destination path.
      #
      def download_tag
        clone(url, target_path)
      end

      # @return [String] Flags for performant git clone
      #
      # @note Due to a workaround in `git`, there's no different specifier
      #       for cloning just a branch, tag or a commit.
      #       Branches and Tags are accepted via `-b my_branch` or `-b 0.1.2`,
      #       but commits aren't.
      #
      # @note That means, we'll need to use a different technique for commits
      #
      # @todo move to private
      #
      def shallow_flags
        flags = [' --single-branch', '--depth 1']
        flags << " -b #{options[:branch]}" if options[:branch]
        flags << " -b #{options[:tag]}" if options[:tag]
        flags.join(' ')
      end
    end
  end
end

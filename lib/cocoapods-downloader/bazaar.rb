module Pod
  module Downloader
    class Bazaar < Base

      def self.options
        [:revision]
      end

      def options_specific?
        !options[:revision].nil?
      end

      def checkout_options
        Dir.chdir(target_path) do
          options = {}
          options[:bzr] = url
          options[:revision] = `bzr revno`.chomp
          options
        end
      end

      private

      executable :bzr

      def download!
        if options[:revision]
          download_revision!
        else
          download_head!
        end
      end

      def download_head!
        bzr! %|branch "#{url}" #{dir_opts} "#{target_path}"|
      end

      def download_revision!
        bzr! %|branch "#{url}" #{dir_opts} -r '#{options[:revision]}' "#{target_path}"|
      end

      def dir_opts
        return '--use-existing-dir' if @target_path.exist?
        ''
      end

    end
  end
end


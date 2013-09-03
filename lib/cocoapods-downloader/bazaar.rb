module Pod
  module Downloader
    class Bazaar < Base

      def self.options
        [:revision, :tag]
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
        if options[:tag]
          download_revision!(options[:tag])
        elsif options[:revision]
          download_revision!(options[:revision])
        else
          download_head!
        end
      end

      def download_head!
        bzr! %|branch "#{url}" #{dir_opts} "#{target_path}"|
      end

      def download_revision!(rev)
        bzr! %|branch "#{url}" #{dir_opts} -r '#{rev}' "#{target_path}"|
      end

      def dir_opts
        return '--use-existing-dir' if @target_path.exist?
        ''
      end

    end
  end
end


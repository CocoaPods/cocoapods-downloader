module Pod
  module Downloader
    class Mercurial < Base

      def self.options
        [:revision]
      end

      def options_specific?
        !options[:revision].nil?
      end

      def checkout_options
        Dir.chdir(target_path) do
          options = {}
          options[:hg] = url
          options[:revision] = `hg --debug id -i`.chomp
          options
        end
      end

      private

      executable :hg

      def download!
        if options[:revision]
          download_revision!
        else
          download_head!
        end
      end

      def download_head!
        hg! %|clone "#{url}" "#{target_path}"|
      end

      def download_revision!
        hg! %|clone "#{url}" --rev '#{options[:revision]}' "#{target_path}"|
      end

    end
  end
end


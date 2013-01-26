module Pod
  module Downloader
    class Subversion < Base

      def self.options
        [:revision, :tag, :folder]
      end

      def options_specific?
        !options[:revision].nil? || !options[:tag].nil?
      end

      def checkout_options
        Dir.chdir(target_path) do
          options = {}
          options[:svn] = url
          options[:revision] = @exported_revision
          options
        end
      end
      private

      executable :svn

      def download!
        output = svn!(%|#{export_subcommand} "#{reference_url}" "#{target_path}"|)
          store_exported_revision(output)
      end

      def download_head!
        output = svn!(%|#{export_subcommand} "#{trunk_url}" "#{target_path}"|)
          store_exported_revision(output)
      end

      def store_exported_revision(output)
        output.match(/Exported revision ([0-9]+)\./)
        @exported_revision = $1
      end

      def export_subcommand
        result = 'export --non-interactive --trust-server-cert --force'
      end

      def reference_url
        result = url.dup
        result << '/'       << options[:folder] if options[:folder]
        result << '/tags/'  << options[:tag] if options[:tag]
        result << '" -r "'  << options[:revision] if options[:revision]
        result
      end

      def trunk_url
        result = url.dup
        result << '/' << options[:folder] if options[:folder]
        result << '/trunk'
        result
      end
    end
  end
end

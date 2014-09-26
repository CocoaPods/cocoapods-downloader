module Pod
  module Downloader
    class Mercurial < Base
      def self.options
        [:revision, :tag, :branch]
      end

      def options_specific?
        !(options[:revision] || options[:tag]).nil?
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
        elsif options[:tag]
          download_tag!
        elsif options[:branch]
          download_branch!
        else
          download_head!
        end
      end

      def download_head!
        hg! %(clone #{url.shellescape} #{@target_path.shellescape})
      end

      def download_revision!
        hg! %(clone #{url.shellescape} --rev #{options[:revision].shellescape} #{@target_path.shellescape})
      end

      def download_tag!
        hg! %(clone #{url.shellescape} --updaterev #{options[:tag].shellescape} #{@target_path.shellescape})
      end

      def download_branch!
        hg! %(clone #{url.shellescape} --updaterev #{options[:branch].shellescape} #{@target_path.shellescape})
      end
    end
  end
end

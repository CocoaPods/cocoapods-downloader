require 'uri'

module Pod
  module Downloader
    require 'cocoapods-downloader/remote_file'

    class Scp < RemoteFile
      DEFAULT_PORT = 22

      def self.options
        super << :port
      end

      private

      executable :scp

      def download_file(full_filename)
        uri = URI.parse(url)
        scp! '-P', port.to_s, '-q', "#{uri.user ? uri.user + '@' : ''}#{uri.host}:'#{uri.path}'", full_filename
      end

      def port
        options[:port] ? options[:port].to_i : DEFAULT_PORT
      end
    end
  end
end

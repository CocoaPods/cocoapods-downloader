require 'zlib'
require 'fileutils'
require 'uri'

module Pod
  module Downloader
    class Http < RemoteFile
      private

      executable :curl

      def download_file(full_filename)
        curl! '-f', '-L', '-o', full_filename, url, '--create-dirs', '--netrc-optional'
      end
    end
  end
end

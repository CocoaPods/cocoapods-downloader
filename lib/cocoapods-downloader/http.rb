module Pod
  module Downloader
    require 'cocoapods-downloader/remote_file'

    class Http < RemoteFile
      private

      executable :curl

      def download_file(full_filename)
        curl! '-f', '-L', '-o', full_filename, url, '--create-dirs', '--netrc-optional'
      end
    end
  end
end

require File.expand_path('../spec_helper', __FILE__)

module Pod
  module Downloader
    describe Base do
      it 'checks for unrecognized options on initialization' do
        options = { :unrecognized => 'value' }
        e = lambda { Base.new('path', 'url', options) }.should.raise DownloaderError
        e.message.should.match /Unrecognized options/
      end
    end
  end
end

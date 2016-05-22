require File.expand_path('../spec_helper', __FILE__)

module Pod
  module Downloader
    describe Base do
      it 'checks for unrecognized options on initialization' do
        options = { :unrecognized => 'value' }
        e = lambda { Base.new('path', 'url', options) }.should.raise DownloaderError
        e.message.should.match /Unrecognized options/
      end

      it 'has no preprocessing' do
        options = { :symbol => 'aaaaaa' }
        new_options = Base.preprocess_options(options)
        new_options.should == options
      end
    end
  end
end

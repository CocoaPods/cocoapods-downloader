require File.expand_path('../../spec_helper', __FILE__)

module Pod
  module Downloader
    describe Base do

      it "checks for unrecognize options on initialization" do
        options = { :unrecognized => 'value' }
        e = lambda { Base.new('path', 'url', options) }.should.raise DownloaderError
        e.message.should.match /Unrecognized options/
      end

      it "return a cache path if the chache root has not been specified" do
        downloader = Base.new('path', 'url', {})
        downloader.cache_path.should.be.nil
      end

      it "return a cache path with the name of the downloader and the hex diggest of the url if the chache root has been specified" do
        downloader = Base.new('path', 'url', {})
        downloader.cache_root = tmp_folder
        downloader.cache_path.relative_path_from(tmp_folder).to_s.should == "Base/81736358b1645103ae83247b10c5f82af641ddfc"
      end

      it "return whether it should use the cache" do
        downloader = Base.new('path', 'url', {})
        downloader.send(:use_cache?).should.be.false

        downloader.cache_root = tmp_folder
        downloader.send(:use_cache?).should.be.true
      end
    end
  end
end

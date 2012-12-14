require File.expand_path('../../spec_helper', __FILE__)

module Pod
  module Downloader
    describe "HTTP" do

      before do
        tmp_folder.rmtree if tmp_folder.exist?
      end

      it "download file and unzip it" do
        options = { :http => 'http://dl.google.com/googleadmobadssdk/googleadmobsearchadssdkios.zip' }
        downloader = Downloader.for_target(tmp_folder, options)
        VCR.use_cassette('tarballs', :record => :new_episodes) { downloader.download }
        tmp_folder('GoogleAdMobSearchAdsSDK/GADSearchRequest.h').should.exist
        tmp_folder('GoogleAdMobSearchAdsSDK/GADSearchRequest.h').read.strip.should =~ /Google Search Ads iOS SDK/
      end

      it "raises if it fails to download" do
        options = { :http => 'broken-link.zip'  }
        downloader = Downloader.for_target(tmp_folder, options)
        lambda { downloader.download }.should.raise DownloaderError
      end

      #-------------------------------------------------------------------------#

      it 'detects zip files' do
        options = { :http => 'https://file.zip' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.send(:type).should == :zip
      end

      it 'detects tar files' do
        options = { :http => 'https://file.tar' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.send(:type).should == :tar
      end

      it 'detects tgz files' do
        options = { :http => 'https://file.tgz' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.send(:type).should == :tgz
      end

      it 'detects tbz files' do
        options = { :http => 'https://file.tbz' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.send(:type).should == :tbz
      end

      it 'allows to specify the file type in the sources' do
        options = { :http => 'https://file', :type => :zip }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.send(:type).should == :zip
      end

      it 'should download file and extract it with proper type' do
        options = { :http => 'https://file.zip' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.expects(:download_file).with(anything())
        downloader.expects(:extract_with_type).with(anything(), :zip).at_least_once
        downloader.download
      end

      it 'should raise error when an unsupported file type is detected' do
        options = { :http => 'https://file.rar' }
        downloader = Downloader.for_target(tmp_folder, options)
        lambda { downloader.download }.should.raise Http::UnsupportedFileTypeError
      end

      it 'should raise error when an unsupported file type is specified in the options' do
        options = { :http => 'https://file', :type => :rar }
        downloader = Downloader.for_target(tmp_folder, options)
        lambda { downloader.download }.should.raise Http::UnsupportedFileTypeError
      end
    end
  end
end

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

      it 'defines a user agent with the cocoapods-downloader version' do
        module TestModuleNoVersion
        end
        Base.user_agent_string(TestModuleNoVersion).should == "cocoapods-downloader/#{Pod::Downloader::VERSION}"
      end

      it 'defines a user agent containing CocoaPods downloader versions when available' do
        module TestModuleWithVersion
          VERSION = 'a.b.c'.freeze
        end
        Base.user_agent_string(TestModuleWithVersion).should ==
          "CocoaPods/#{TestModuleWithVersion::VERSION} cocoapods-downloader/#{Pod::Downloader::VERSION}"
      end
    end
  end
end

require File.expand_path('../../spec_helper', __FILE__)

module Pod
  module Downloader
    describe "Subversion" do

      before do
        tmp_folder.rmtree if tmp_folder.exist?
      end

      it "check's out a specific revision" do
        options = { :svn => "file://#{fixture('subversion-repo')}", :revision => '1' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'first commit'
      end

      it "check's out a specific tag" do
        options = { :svn => "file://#{fixture('subversion-repo')}", :tag => 'tag-1' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'tag 1'
      end

      it "check's out the head version" do
        options = { :svn => "file://#{fixture('subversion-repo')}", :tag => 'tag-1' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download_head
        tmp_folder('README').read.strip.should == 'unintersting'
      end

      it "returns the checked out revision" do
        options = { :svn => "file://#{fixture('subversion-repo')}" }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        downloader.checkout_options.should == {
          :svn => "file://#{fixture('subversion-repo')}",
          :revision => '12'
        }
      end

      it "raises if it fails to download" do
        options = { :svn => 'missing-repo', :revision => '1' }
        downloader = Downloader.for_target(tmp_folder, options)
        lambda { downloader.download }.should.raise DownloaderError
      end
    end
  end
end

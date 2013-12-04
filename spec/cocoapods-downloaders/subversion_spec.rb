require File.expand_path('../../spec_helper', __FILE__)

module Pod
  module Downloader
    describe "Subversion" do

      before do
        tmp_folder.rmtree if tmp_folder.exist?
      end

      it "checks out a specific revision" do
        options = { :svn => "file://#{fixture('subversion-repo')}", :revision => '1' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'first commit'
      end

      it "checks out a specific tag" do
        options = { :svn => "file://#{fixture('subversion-repo')}", :tag => 'tag-1' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'tag 1'
      end

      it "checks out the head version" do
        options = { :svn => "file://#{fixture('subversion-repo')}", :tag => 'tag-1' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download_head
        tmp_folder('README').read.strip.should == 'unintersting'
      end

      describe "when the directory name has quotes" do
        it "checks out a specific revision" do
          options = { :svn => "file://#{fixture('subversion-repo')}", :revision => '1' }
          downloader = Downloader.for_target(tmp_folder_with_quotes, options)
          downloader.download
          tmp_folder_with_quotes('README').read.strip.should == 'first commit'
        end

        it "checks out the head version" do
          options = { :svn => "file://#{fixture('subversion-repo')}", :tag => 'tag-1' }
          downloader = Downloader.for_target(tmp_folder_with_quotes, options)
          downloader.download_head
          tmp_folder_with_quotes('README').read.strip.should == 'unintersting'
        end
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

      it "returns whether the provided options are specific" do
        Downloader.for_target('path', :svn => 'url').options_specific?.should.be.false
        Downloader.for_target('path', :svn => 'url', :folder => '').options_specific?.should.be.false
        Downloader.for_target('path', :svn => 'url', :revision => '').options_specific?.should.be.true
        Downloader.for_target('path', :svn => 'url', :tag => '').options_specific?.should.be.true
      end

      it "raises if it fails to download" do
        options = { :svn => 'missing-repo', :revision => '1' }
        downloader = Downloader.for_target(tmp_folder, options)
        lambda { downloader.download }.should.raise DownloaderError
      end
    end
  end
end

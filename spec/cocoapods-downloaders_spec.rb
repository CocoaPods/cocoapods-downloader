require File.expand_path('../spec_helper', __FILE__)

module Pod
  module Downloader
    describe Downloader do

      before do
        tmp_folder.rmtree if tmp_folder.exist?
      end

      it "returns the Git downloader" do
        concrete = Downloader.for_target(tmp_folder, :git => 'url')
        concrete.class.should == Downloader::Git
      end

      it "returns the Mercurial downloader" do
        concrete = Downloader.for_target(tmp_folder, :hg => 'Mercurial')
        concrete.class.should == Downloader::Mercurial
      end

      it "returns the Subversion downloader" do
        concrete = Downloader.for_target(tmp_folder, :svn => 'Subversion')
        concrete.class.should == Downloader::Subversion
      end

      it "returns the Http downloader" do
        concrete = Downloader.for_target(tmp_folder, :http => 'Http')
        concrete.class.should == Downloader::Http
      end

      it "returns the GitHub downloader" do
        concrete = Downloader.for_target(tmp_folder, :git => 'www.github.com/path')
        concrete.class.should == Downloader::GitHub
      end

      it "returns passes the url to the concrete instance" do
        concrete = Downloader.for_target(tmp_folder, :git => 'url')
        concrete.url.should == 'url'
      end

    end
  end
end

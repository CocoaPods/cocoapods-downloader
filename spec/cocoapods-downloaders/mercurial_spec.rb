require File.expand_path('../../spec_helper', __FILE__)

module Pod
  module Downloader
    describe "Mercurial" do

      before do
        tmp_folder.rmtree if tmp_folder.exist?
      end

      it "checks out a specific revision" do
        options = { :hg => fixture('mercurial-repo'), :revision => '46198bb3af96' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'first commit'
      end

      it "checks out the head revision" do
        options = { :hg => fixture('mercurial-repo') }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'second commit'
      end

      describe "when the directory name has quotes or spaces" do
        it "checks out a specific revision" do
          options = { :hg => fixture('mercurial-repo'), :revision => '46198bb3af96' }
          downloader = Downloader.for_target(tmp_folder_with_quotes, options)
          downloader.download
          tmp_folder_with_quotes('README').read.strip.should == 'first commit'
        end

        it "checks out the head revision" do
          options = { :hg => fixture('mercurial-repo') }
          downloader = Downloader.for_target(tmp_folder_with_quotes, options)
          downloader.download
          tmp_folder_with_quotes('README').read.strip.should == 'second commit'
        end
      end

      it "returns the checked out revision" do
        options = { :hg => fixture('mercurial-repo') }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        downloader.checkout_options.should == {
          :hg => fixture('mercurial-repo'),
          :revision => "df97b9ee89577f2da1925154472888b2b57e971e"
        }
      end

      it "returns whether the provided options are specific" do
        Downloader.for_target('path', :hg => 'url').options_specific?.should.be.false
        Downloader.for_target('path', :hg => 'url', :revision => '').options_specific?.should.be.true
      end

      it "raises if it fails to download" do
        options = { :hg => 'missing-repo', :revision => '46198bb3af96' }
        downloader = Downloader.for_target(tmp_folder, options)
        lambda { downloader.download }.should.raise DownloaderError
      end
    end
  end
end

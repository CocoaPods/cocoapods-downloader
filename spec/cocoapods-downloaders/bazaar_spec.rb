require File.expand_path('../../spec_helper', __FILE__)

module Pod
  module Downloader
    describe 'Bazaar' do

      before do
        tmp_folder.rmtree if tmp_folder.exist?
      end

      it 'checks out a specific revision' do
        options = { :bzr => fixture('bazaar-repo'), :revision => '1' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'First Commit'
      end

      it 'checks out a specific tag as a revision' do
        options = { :bzr => fixture('bazaar-repo'), :revision => 'my_tag' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'Second Commit'
      end

      it 'checks out a specific tag as a tag' do
        options = { :bzr => fixture('bazaar-repo'), :tag => 'my_other_tag' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'Third Commit'
      end

      it 'checks out the head revision' do
        options = { :bzr => fixture('bazaar-repo') }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'Fourth Commit'
      end

      it 'returns the checked out revision' do
        options = { :bzr => fixture('bazaar-repo') }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        downloader.checkout_options.should == {
          :bzr => fixture('bazaar-repo'),
          :revision => '4'
        }
      end

      it 'returns whether the provided options are specific' do
        Downloader.for_target('path', :bzr => 'url').options_specific?.should.be.false
        Downloader.for_target('path', :bzr => 'url', :revision => '').options_specific?.should.be.true
      end

      it 'raises if it fails to download' do
        options = { :bzr => 'missing-repo', :revision => '12' }
        downloader = Downloader.for_target(tmp_folder, options)
        lambda { downloader.download }.should.raise DownloaderError
      end
    end
  end
end

require File.expand_path('../spec_helper', __FILE__)

module Pod
  module Downloader
    describe 'Mercurial' do
      before do
        tmp_folder.rmtree if tmp_folder.exist?
      end

      it 'checks out a specific revision' do
        options = { :hg => fixture('mercurial-repo'), :revision => '46198bb3af96' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'first commit'
      end

      it 'checks out the head revision' do
        options = { :hg => fixture('mercurial-repo') }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'second commit'
      end

      it 'returns whether it supports the download of the head' do
        options = { :hg => fixture('mercurial-repo') }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.head_supported?.should.be.true
      end

      describe 'when the directory name has quotes or spaces' do
        it 'checks out a specific revision' do
          options = { :hg => fixture('mercurial-repo'), :revision => '46198bb3af96' }
          downloader = Downloader.for_target(tmp_folder_with_quotes, options)
          downloader.download
          tmp_folder_with_quotes('README').read.strip.should == 'first commit'
        end

        it 'checks out the head revision' do
          options = { :hg => fixture('mercurial-repo') }
          downloader = Downloader.for_target(tmp_folder_with_quotes, options)
          downloader.download
          tmp_folder_with_quotes('README').read.strip.should == 'second commit'
        end

        it 'checks out a specific tag' do
          options = { :hg => fixture('mercurial-repo'), :tag => '1.0.0' }
          downloader = Downloader.for_target(tmp_folder_with_quotes, options)
          downloader.download
          tmp_folder_with_quotes('README').read.strip.should == 'third commit'
        end

        it 'checks out the branch head revision' do
          options = { :hg => fixture('mercurial-repo'), :branch => 'feature/feature-branch' }
          downloader = Downloader.for_target(tmp_folder_with_quotes, options)
          downloader.download
          tmp_folder_with_quotes('README').read.strip.should == 'fourth commit'
        end
      end

      it 'returns the checked out revision' do
        options = { :hg => fixture('mercurial-repo') }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        downloader.checkout_options.should == {
          :hg => fixture('mercurial-repo'),
          :revision => 'df97b9ee89577f2da1925154472888b2b57e971e',
        }
      end

      it 'returns whether the provided options are specific' do
        Downloader.for_target('path', :hg => 'url').options_specific?.should.be.false
        Downloader.for_target('path', :hg => 'url', :revision => '').options_specific?.should.be.true
        Downloader.for_target('path', :hg => 'url', :tag => '').options_specific?.should.be.true
        Downloader.for_target('path', :hg => 'url', :branch => '').options_specific?.should.be.false
      end

      it 'raises if it fails to download' do
        options = { :hg => 'missing-repo', :revision => '46198bb3af96' }
        downloader = Downloader.for_target(tmp_folder, options)
        lambda { downloader.download }.should.raise DownloaderError
      end

      it 'checks out a specific tag' do
        options = { :hg => fixture('mercurial-repo'), :tag => '1.0.0' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        downloader.checkout_options.should == {
          :hg => fixture('mercurial-repo'),
          :revision => '3c8b8d211b03c7e686049a8558e4c297104291eb',
        }
      end

      it 'checks out a specific branch head' do
        options = { :hg => fixture('mercurial-repo'), :branch => 'feature/feature-branch' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        downloader.checkout_options.should == {
          :hg => fixture('mercurial-repo'),
          :revision => '61118fa8988c2b2eae826f48abd1e3340dae0c6b',
        }
      end

      it 'has no preprocessing' do
        options = { :hg => fixture('mercurial-repo'), :tag => '1.0.0' }
        new_options = Downloader.preprocess_options(options)
        new_options.should == options
      end
    end
  end
end

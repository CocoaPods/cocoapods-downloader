require File.expand_path('../spec_helper', __FILE__)

module Pod
  module Downloader
    describe 'Subversion' do
      before do
        tmp_folder.rmtree if tmp_folder.exist?
      end

      it 'checks out a specific revision' do
        options = { :svn => "file://#{fixture('subversion-repo')}", :revision => '1' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'first commit'
        tmp_folder('.svn').should.not.exist
      end

      it 'checks out a specific tag' do
        options = { :svn => "file://#{fixture('subversion-repo')}", :tag => 'tag-1' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'tag 1'
      end

      it 'checks out the head version' do
        options = { :svn => "file://#{fixture('subversion-repo')}", :tag => 'tag-1' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download_head
        tmp_folder('README').read.strip.should == 'unintersting'
      end

      it 'returns whether it supports the download of the head' do
        options = { :svn => "file://#{fixture('subversion-repo')}", :tag => 'tag-1' }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.head_supported?.should.be.true
      end

      describe 'when the directory name has quotes or spaces' do
        it 'checks out a specific revision' do
          options = { :svn => "file://#{fixture('subversion-repo')}", :revision => '1' }
          downloader = Downloader.for_target(tmp_folder_with_quotes, options)
          downloader.download
          tmp_folder_with_quotes('README').read.strip.should == 'first commit'
        end

        it 'checks out the head version' do
          options = { :svn => "file://#{fixture('subversion-repo')}", :tag => 'tag-1' }
          downloader = Downloader.for_target(tmp_folder_with_quotes, options)
          downloader.download_head
          tmp_folder_with_quotes('README').read.strip.should == 'unintersting'
        end
      end

      it 'returns the checked out revision' do
        options = { :svn => "file://#{fixture('subversion-repo')}" }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        downloader.checkout_options.should == {
          :svn => "file://#{fixture('subversion-repo')}",
          :revision => '12',
        }
      end

      it 'returns whether the provided options are specific' do
        Downloader.for_target('path', :svn => 'url').options_specific?.should.be.false
        Downloader.for_target('path', :svn => 'url', :folder => '').options_specific?.should.be.false
        Downloader.for_target('path', :svn => 'url', :revision => '').options_specific?.should.be.true
        Downloader.for_target('path', :svn => 'url', :tag => '').options_specific?.should.be.true
      end

      it 'raises if it fails to download' do
        options = { :svn => 'missing-repo', :revision => '1' }
        downloader = Downloader.for_target(tmp_folder, options)
        lambda { downloader.download }.should.raise DownloaderError
      end

      it 'updates externals by default' do
        FileUtils.rm_rf('/tmp/subversion-external-repo')
        FileUtils.cp_r(fixture('subversion-repo'), '/tmp/subversion-external-repo')
        options = { :svn => "file://#{fixture('subversion-refs-externals-repo')}", :revision => 'r3' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('trunk/README.txt').should.exist?
        tmp_folder('external/README').should.exist?
        FileUtils.rm_rf('/tmp/subversion-external-repo')
      end

      it "doesn't update externals when requested" do
        options = { :svn => "file://#{fixture('subversion-refs-externals-repo')}", :revision => 'r3', :externals => false }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('trunk/README.txt').should.exist?
        tmp_folder('external/README').should.not.exist?
      end

      it 'checks out a specific revision' do
        options = {
          :svn => "file://#{fixture('subversion-repo')}",
          :revision => '1',
          :checkout => true,
        }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'first commit'
        tmp_folder('.svn').should.exist
      end

      it 'has no preprocessing' do
        options = {
          :svn => "file://#{fixture('subversion-repo')}",
          :revision => '1',
          :checkout => true,
        }
        new_options = Downloader.preprocess_options(options)
        new_options.should == options
      end
    end
  end
end

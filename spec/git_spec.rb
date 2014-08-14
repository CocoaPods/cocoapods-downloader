require File.expand_path('../spec_helper', __FILE__)

module Pod
  module Downloader
    describe 'Git' do

      before do
        tmp_folder.rmtree if tmp_folder.exist?
      end

      it 'checks out a specific commit' do
        options = { :git => fixture('git-repo'), :commit => '7ad3a6c' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'first commit'
      end

      describe 'shallow cloning' do
        def ensure_only_one_ref(folder)
          Dir.chdir(folder) do
            `git rev-list --count HEAD`.strip.should == '1'
          end
        end

        # @note This is only needed for __shallow__ cloning local repos,
        #       it requires file:// prefix in order to be treated as remote.
        #       Otherwise it will perform normal clone
        #
        def local_fixture(name)
          'file://' + fixture(name).to_s
        end

        before do
          FileUtils.rm_rf('/tmp/git-submodule-repo')
          FileUtils.cp_r(fixture('git-submodule-repo'), '/tmp/')
        end

        after do
          FileUtils.rm_rf('/tmp/git-submodule-repo')
        end

        it 'uses shallow clone' do
          options = { :git => local_fixture('git-repo') }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download

          ensure_only_one_ref(tmp_folder)
        end

        it 'clones a specific branch' do
          options = { :git => local_fixture('git-repo'), :branch => 'topic_branch' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download

          tmp_folder('README').read.strip.should == 'topic_branch'
          ensure_only_one_ref(tmp_folder)
        end

        it 'clones a specific tag' do
          options = { :git => local_fixture('git-repo'), :tag => 'v1.0' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download

          tmp_folder('README').read.strip.should == 'v1.0'
          ensure_only_one_ref(tmp_folder)
        end

        it 'clones a specific commit' do
          options = { :git => local_fixture('git-repo'), :commit => '407e385' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download

          Dir.chdir(tmp_folder) do
            `git rev-list HEAD`.chomp.should.include '407e385'
          end
        end

        it 'shallow clones submodules' do
          options = { :git => local_fixture('git-repo'), :submodules => true }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download

          ensure_only_one_ref("#{tmp_folder}/submodule")
        end

      end

      it 'checks out when the path contains quotes or spaces' do
        options = { :git => fixture('git-repo'), :commit => '7ad3a6c' }
        downloader = Downloader.for_target(tmp_folder_with_quotes, options)
        downloader.download
        tmp_folder_with_quotes('README').read.strip.should == 'first commit'
      end

      it 'checks out a specific branch' do
        options = { :git => fixture('git-repo'), :branch => 'topic_branch' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'topic_branch'
      end

      it 'checks out a specific tag' do
        options = { :git => fixture('git-repo'), :tag => 'v1.0' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'v1.0'
      end

      it "doesn't updates submodules by default" do
        options = { :git => fixture('git-repo'), :commit => 'd7f4104' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'added submodule'
        tmp_folder('submodule/README').should.not.exist?
      end

      it 'initializes submodules when requested' do
        FileUtils.rm_rf('/tmp/git-submodule-repo')
        FileUtils.cp_r(fixture('git-submodule-repo'), '/tmp/')
        options = { :git => fixture('git-repo'), :commit => 'd7f4104', :submodules => true }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'added submodule'
        tmp_folder('submodule/README').read.strip.should == 'submodule'
        FileUtils.rm_rf('/tmp/git-submodule-repo')
      end

      it 'returns whether it supports the download of the head' do
        options = { :git => fixture('git-repo') }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.head_supported?.should.be.true
      end

      it 'returns whether the provided options are specific' do
        Downloader.for_target('path', :git => 'url').options_specific?.should.be.false
        Downloader.for_target('path', :git => 'url', :branch => '').options_specific?.should.be.false
        Downloader.for_target('path', :git => 'url', :submodules => '').options_specific?.should.be.false

        Downloader.for_target('path', :git => 'url', :commit => '').options_specific?.should.be.true
        Downloader.for_target('path', :git => 'url', :tag => '').options_specific?.should.be.true
      end

      it 'returns the checked out revision' do
        options = { :git => fixture('git-repo') }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        downloader.checkout_options.should == {
          :git => fixture('git-repo'),
          :commit => 'd7f410490dabf7a6bde665ba22da102c3acf1bd9'
        }
      end

      #--------------------------------------#

      it "raises if it can't find the url" do
        options = { :git => 'missing-repo' }
        downloader = Downloader.for_target(tmp_folder, options)
        lambda { downloader.download }.should.raise DownloaderError
      end

      it "raises if it can't find a commit" do
        options = { :git => fixture('git-repo'), :commit => 'aaaaaa' }
        downloader = Downloader.for_target(tmp_folder, options)
        lambda { downloader.download }.should.raise DownloaderError
      end

      it "raises if it can't find a tag" do
        options = { :git => fixture('git-repo'), :tag => 'aaaaaa' }
        downloader = Downloader.for_target(tmp_folder, options)
        lambda { downloader.download }.should.raise DownloaderError
      end

      it "raises if it can't find a reference" do
        options = { :git => fixture('git-repo'), :commit => 'aaaaaa' }
        downloader = Downloader.for_target(tmp_folder, options)
        lambda { downloader.download }.should.raise DownloaderError
      end
    end
  end
end

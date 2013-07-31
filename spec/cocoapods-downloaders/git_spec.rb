require File.expand_path('../../spec_helper', __FILE__)

module Pod
  module Downloader
    describe "Git" do

      before do
        tmp_folder.rmtree if tmp_folder.exist?
      end

      it "checks out a specific commit" do
        options = { :git => fixture('git-repo'), :commit => '7ad3a6c' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'first commit'
      end

      it "checks out a specific branch" do
        options = { :git => fixture('git-repo'), :branch => 'topic_branch' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'topic_branch'
      end

      it "checks out a specific tag" do
        options = { :git => fixture('git-repo'), :tag => 'v1.0' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'v1.0'
      end

      it "checks out a specific tag using git clone when a cache is available for performance" do
        options = { :git => fixture('git-repo'), :tag => 'v1.0' }
        downloader = Downloader.for_target(tmp_folder('destination'), options)
        downloader.cache_root = tmp_folder('cache')
        def downloader.execute_command(executable, command, raise_on_failure = false)
          @spec_commands_log ||= []
          @spec_commands_log << command
        end
        downloader.download
        commands = downloader.instance_variable_get("@spec_commands_log").join("\n")
        commands.should.not.include("init")
      end

      it "doesn't updates submodules by default" do
        options = { :git => fixture('git-repo'), :commit => 'd7f4104' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'added submodule'
        tmp_folder('submodule/README').should.not.exist?
      end

      it "initializes submodules when requested" do
        FileUtils.rm_rf('/tmp/git-submodule-repo')
        FileUtils.cp_r(fixture('git-submodule-repo'), '/tmp/')
        options = { :git => fixture('git-repo'), :commit => 'd7f4104', :submodules => true }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('README').read.strip.should == 'added submodule'
        tmp_folder('submodule/README').read.strip.should == 'submodule'
        FileUtils.rm_rf('/tmp/git-submodule-repo')
      end

      #--------------------------------------#

      it "prepares the cache if it does not exist" do
        options = { :git => fixture('git-repo'), :commit => '7ad3a6c' }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.cache_root = tmp_folder('cache')
        downloader.cache_path.rmtree if downloader.cache_path.exist?
        downloader.expects(:create_cache).once
        downloader.stubs(:download_commit)
        downloader.download
      end

      it "prepares the cache if it does not exist when the HEAD is requested explicitly" do
        options = { :git => fixture('git-repo') }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.cache_root = tmp_folder('cache')
        downloader.cache_path.rmtree if downloader.cache_path.exist?
        downloader.expects(:create_cache).once
        downloader.stubs(:clone)
        downloader.download_head
      end

      # TODO move to base
      #
      it "removes the oldest repo if the caches is too big" do
        options = { :git => fixture('git-repo'), :commit => '7ad3a6c' }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.cache_root = tmp_folder('cache')
        downloader.max_cache_size = 0
        downloader.download
        downloader.cache_path.should.not.exist?
      end

      it "returns whether the provided options are specific" do
        Downloader.for_target('path', :git => 'url').options_specific?.should.be.false
        Downloader.for_target('path', :git => 'url', :branch => '').options_specific?.should.be.false
        Downloader.for_target('path', :git => 'url', :submodules => '').options_specific?.should.be.false

        Downloader.for_target('path', :git => 'url', :commit => '').options_specific?.should.be.true
        Downloader.for_target('path', :git => 'url', :tag => '').options_specific?.should.be.true
      end

      it "returns the checked out revision" do
        options = { :git => fixture('git-repo') }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        downloader.checkout_options.should == {
          :git => fixture('git-repo'),
          :commit => "d7f410490dabf7a6bde665ba22da102c3acf1bd9"
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

      #--------------------------------------#

      it "returns the cache directory as the clone url" do
        options = { :git => fixture('git-repo'), :commit => '7ad3a6c' }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.cache_root = tmp_folder('cache')
        downloader.send(:clone_url).to_s.should.match /tmp\/cache\/Git/
      end

      it "updates the cache if the HEAD is requested" do
        options = { :git => fixture('git-repo') }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.cache_root = tmp_folder('cache')
        downloader.expects(:update_cache).once
        downloader.download
      end

      it "updates the cache if the ref is not available" do
        # create the origin repo and the cache
        tmp_repo_path = tmp_folder + 'git-repo-source'
        `git clone #{fixture('git-repo')} #{tmp_repo_path}`
        options = { :git => tmp_repo_path, :commit => '7ad3a6c' }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.download

        # make a new commit in the origin
        commit = ''
        Dir.chdir(tmp_repo_path) do
          `touch test.txt`
          `git add test.txt`
          `git commit -m 'test'`
          commit = `git rev-parse HEAD`.chomp
        end

        # require the new commit
        options = { :git => tmp_repo_path, :commit => commit }
        downloader = Downloader.for_target(tmp_folder('checkout-1'), options)
        downloader.download
        tmp_folder('checkout-1/test.txt').should.exist?
      end

      it "doesn't update the cache if the ref is available" do
        options = { :git => fixture('git-repo'), :commit => '7ad3a6c' }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.cache_root = tmp_folder('cache')
        downloader.download
        tmp_folder.rmtree
        downloader.expects(:update_cache).never
        downloader.download
      end

      it "update the cache if the tag is available by default" do
        options = { :git => fixture('git-repo'), :tag => 'v1.0' }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.cache_root = tmp_folder('cache')
        downloader.download
        tmp_folder('checkout').rmtree
        downloader.expects(:update_cache).once
        downloader.download
      end

      it "doesn't update the cache if the tag is available and the aggressive cache option is specified" do
        options = { :git => fixture('git-repo'), :tag => 'v1.0' }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.cache_root = tmp_folder('cache')
        downloader.aggressive_cache = true
        downloader.download
        tmp_folder('checkout').rmtree
        downloader.expects(:update_cache).never
        downloader.download
      end

      it "always updates the cache if a branch requested" do
        options = { :git => fixture('git-repo'), :branch => 'master' }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.cache_root = tmp_folder('cache')
        downloader.download
        tmp_folder.rmtree
        downloader.expects(:update_cache).once
        downloader.download
      end

    end

    #---------------------------------------------------------------------------#

    describe "for GitHub repositories, with :download_only set to true" do

      before do
        tmp_folder.rmtree if tmp_folder.exist?
      end

      it "downloads HEAD with no other options specified" do
        options = { :git => "git://github.com/lukeredpath/libPusher.git", :download_only => true }
        downloader = Downloader.for_target(tmp_folder, options)
        VCR.use_cassette('tarballs', :record => :new_episodes) { downloader.download }
        tmp_folder('README.md').readlines[0].should =~ /libPusher/
      end

      it "downloads a specific tag when specified" do
        options = { :git => "git://github.com/lukeredpath/libPusher.git", :tag => 'v1.1', :download_only => true }
        downloader = Downloader.for_target(tmp_folder, options)
        VCR.use_cassette('tarballs', :record => :new_episodes) { downloader.download }
        tmp_folder('libPusher.podspec').readlines.grep(/1.1/).should.not.be.empty
      end

      it "downloads a specific branch when specified" do
        options = { :git => "git://github.com/lukeredpath/libPusher.git", :branch => 'gh-pages', :download_only => true }
        downloader = Downloader.for_target(tmp_folder, options)
        VCR.use_cassette('tarballs', :record => :new_episodes) { downloader.download }
        tmp_folder('index.html').readlines.grep(/libPusher Documentation/).should.not.be.empty
      end

      it "downloads a specific commit when specified" do
        options = { :git => "git://github.com/lukeredpath/libPusher.git", :commit => 'eca89998d5', :download_only => true }
        downloader = Downloader.for_target(tmp_folder, options)
        VCR.use_cassette('tarballs', :record => :new_episodes) { downloader.download }
        tmp_folder('README.md').readlines[0].should =~ /PusherTouch/
      end

      #--------------------------------------@

      it 'can convert public HTTP repository URLs to the tarball URL' do
        options = { :git => "https://github.com/CocoaPods/CocoaPods.git" }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.tarball_url_for('master').should == "https://github.com/CocoaPods/CocoaPods/tarball/master"
      end

      it 'can convert private HTTP repository URLs to the tarball URL' do
        options = { :git => "https://lukeredpath@github.com/CocoaPods/CocoaPods.git" }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.tarball_url_for('master').should == "https://github.com/CocoaPods/CocoaPods/tarball/master"
      end

      it 'can convert private SSH repository URLs to the tarball URL' do
        options = { :git => "git@github.com:CocoaPods/CocoaPods.git" }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.tarball_url_for('master').should == "https://github.com/CocoaPods/CocoaPods/tarball/master"
      end

      it 'can convert public git protocol repository URLs to the tarball URL' do
        options = { :git => "git://github.com/CocoaPods/CocoaPods.git" }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.tarball_url_for('master').should == "https://github.com/CocoaPods/CocoaPods/tarball/master"
      end
    end
  end
end

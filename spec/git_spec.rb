require File.expand_path('../spec_helper', __FILE__)

module Pod
  module Downloader
    describe 'Git' do
      def fixture_url(name)
        'file://' + fixture(name).to_s
      end

      before do
        tmp_folder.rmtree if tmp_folder.exist?
      end

      describe 'In general' do
        it 'checks out a specific commit' do
          options = { :git => fixture('git-repo'), :commit => '7ad3a6c' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download
          tmp_folder('README').read.strip.should == 'first commit'
        end

        it 'checks out a specific branch' do
          options = { :git => fixture('git-repo'), :branch => 'topic_branch' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download
          tmp_folder('README').read.strip.should == 'topic_branch'
        end

        it 'checks out a specific branch with forced encoding' do
          options = { :git => fixture('git-repo'), :branch => '中文分支' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download
          tmp_folder('README').read.strip.should == '中文分支'
        end

        it 'checks out a specific tag' do
          options = { :git => fixture('git-repo'), :tag => 'v1.0' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download
          tmp_folder('README').read.strip.should == 'v1.0'
        end

        it 'downloads the head of a repo' do
          options = { :git => fixture('git-repo') }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download_head
          Dir.chdir(tmp_folder) do
            `git rev-list HEAD`.chomp.should.include '98cbf14'
          end
        end

        it 'downloads the head of a repo if no specific options are provided' do
          options = { :git => fixture('git-repo') }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download
          Dir.chdir(tmp_folder) do
            `git rev-list HEAD`.chomp.should.include '98cbf14'
          end
        end

        it "doesn't initializes submodules by default" do
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

          downloader.checkout_options.should == {
            :git => fixture('git-repo'),
            :commit => 'd7f410490dabf7a6bde665ba22da102c3acf1bd9',
            :submodules => true,
          }
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
            :commit => '98cbf14201a78b56c6b7290f6cac840a7597a1c2',
          }
        end
      end

      describe 'Shallow cloning' do
        def ensure_only_one_ref(folder)
          Dir.chdir(folder) do
            `git rev-list --count HEAD`.strip.should == '1'
          end
        end

        before do
          FileUtils.rm_rf('/tmp/git-submodule-repo')
          FileUtils.cp_r(fixture('git-submodule-repo'), '/tmp/')
        end

        it 'uses shallow clone' do
          options = { :git => fixture_url('git-repo') }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download

          ensure_only_one_ref(tmp_folder)
        end

        it 'clones a specific branch' do
          options = { :git => fixture_url('git-repo'), :branch => 'topic_branch' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download

          tmp_folder('README').read.strip.should == 'topic_branch'
          ensure_only_one_ref(tmp_folder)
        end

        it 'clones a specific tag' do
          options = { :git => fixture_url('git-repo'), :tag => 'v1.0' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download

          tmp_folder('README').read.strip.should == 'v1.0'
          ensure_only_one_ref(tmp_folder)
        end

        it 'clones a specific commit' do
          options = { :git => fixture_url('git-repo'), :commit => '407e385' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download

          Dir.chdir(tmp_folder) do
            `git rev-list HEAD`.chomp.should.include '407e385'
          end
        end
      end

      describe 'Robustness' do
        it 'supports path contains quotes or spaces' do
          options = { :git => fixture('git-repo'), :commit => '7ad3a6c' }
          downloader = Downloader.for_target(tmp_folder_with_quotes, options)
          downloader.download
          tmp_folder_with_quotes('README').read.strip.should == 'first commit'
        end

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

        it 'is not confused by specific options in download head' do
          options = { :git => fixture_url('git-repo'), :tag => 'v1.0' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.download_head
          Dir.chdir(tmp_folder) do
            `git rev-list HEAD`.chomp.should.include '98cbf14'
          end
        end

        describe 'will retry if a remote does not support shallow clones' do
          it 'with git <= 2.10.x' do
            options = { :git => fixture_url('git-repo'), :tag => 'v1.0' }
            downloader = Downloader.for_target(tmp_folder, options)
            message = '/usr/local/bin/git clone URL directory --single-branch ' \
              "--depth 1\nCloning into 'directory'...\n" \
              'fatal: dumb http transport does not support --depth'
            dumb_remote_error = Pod::Downloader::DownloaderError.new(message)
            downloader.stubs(:git!).raises(dumb_remote_error).then.returns(true)
            should.not.raise { downloader.download }
          end

          it 'with git >= 2.11.x' do
            options = { :git => fixture_url('git-repo'), :tag => 'v1.0' }
            downloader = Downloader.for_target(tmp_folder, options)
            message = '/usr/local/bin/git clone URL directory --single-branch ' \
              "--depth 1\nCloning into 'directory'...\n" \
              'fatal: dumb http transport does not support shallow capabilities'
            dumb_remote_error = Pod::Downloader::DownloaderError.new(message)
            downloader.stubs(:git!).raises(dumb_remote_error).then.returns(true)
            should.not.raise { downloader.download }
          end
        end
      end

      describe ':commit_from_ls_remote' do
        it 'finds commit for a branch' do
          test_commit = 'abcde'
          test_branch = 'stable'
          test_output = "#{test_commit}\trefs/heads/#{test_branch}"
          result = Git.send(:commit_from_ls_remote, test_output, test_branch)
          result.should == test_commit
        end
        it 'returns nil for no match' do
          test_commit = 'abcde'
          test_branch = 'stable'
          test_output = "#{test_commit}\trefs/heads/other_branch"
          result = Git.send(:commit_from_ls_remote, test_output, test_branch)
          result.should.nil?
        end
        it 'can match a commit for a tag' do
          test_commit = '12345'
          test_branch = 'stable'
          test_output = "#{test_commit}\trefs/tags/#{test_branch}"
          result = Git.send(:commit_from_ls_remote, test_output, test_branch)
          result.should == test_commit
        end
        it 'finds correct commit from multiple ls-remote branches' do
          test_commit1 = 'abcde'
          test_branch1 = 'stable'
          test_commit2 = '12345'
          test_branch2 = 'release/stable'
          test_output = "#{test_commit1}\trefs/heads/#{test_branch1}\n#{test_commit2}\trefs/heads/#{test_branch2}"
          result1 = Git.send(:commit_from_ls_remote, test_output, test_branch1)
          result1.should == test_commit1
          result2 = Git.send(:commit_from_ls_remote, test_output, test_branch2)
          result2.should == test_commit2
        end
        it 'returns a branch over a tag' do
          test_commit1 = 'abcde'
          test_branch = 'stable'
          test_commit2 = '12345'
          test_output = "#{test_commit1}\trefs/heads/#{test_branch}\n#{test_commit2}\trefs/tags/#{test_branch}"
          result = Git.send(:commit_from_ls_remote, test_output, test_branch)
          result.should == test_commit1
        end
        it 'handles nil inputs' do
          Git.send(:commit_from_ls_remote, nil, 'test_branch').should.nil?
          Git.send(:commit_from_ls_remote, "123\trefs/heads/abc", nil).should.nil?
        end
      end

      describe '::preprocess_options' do
        it 'skips non-branch requests' do
          options = { :git => fixture_url('git-repo'), :commit => 'aaaa' }
          new_options = Downloader.preprocess_options(options)
          options.should == new_options
        end

        it 'resolves master to a commit' do
          options = { :git => fixture_url('git-repo'), :branch => 'master' }
          new_options = Downloader.preprocess_options(options)
          new_options[:commit].should == '98cbf14201a78b56c6b7290f6cac840a7597a1c2'
        end

        it 'ignores invalid branches' do
          options = { :git => fixture_url('git-repo'), :branch => 'aaaa' }
          new_options = Downloader.preprocess_options(options)
          new_options[:branch].should == 'aaaa'
        end
      end
    end
  end
end

require File.expand_path('../spec_helper', __FILE__)

module Pod
  module Downloader
    describe 'HTTP' do
      before do
        tmp_folder.rmtree if tmp_folder.exist?
        @fixtures_url = 'file://' + fixture('http').to_s
      end

      it 'download file and unzip it' do
        options = { :http => "#{@fixtures_url}/lib.zip" }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('lib/file.txt').should.exist
        tmp_folder('lib/file.txt').read.strip.should =~ /This is a fixture/
      end

      it 'download file and extract it' do
        options = { :http => "#{@fixtures_url}/lib.dmg" }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('lib/file.txt').should.exist
        tmp_folder('lib/file.txt').read.strip.should =~ /This is a fixture/
      end

      it 'ignores any params in the url' do
        options = { :http => "#{@fixtures_url}/lib.zip?param=value" }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.send(:type).should == :zip
      end

      it 'should download file and unzip it when the target folder name contains quotes or spaces' do
        options = { :http => "#{@fixtures_url}/lib.zip" }
        downloader = Downloader.for_target(tmp_folder_with_quotes, options)
        downloader.download
        tmp_folder_with_quotes('lib/file.txt').should.exist
        tmp_folder_with_quotes('lib/file.txt').read.strip.should =~ /This is a fixture/
      end

      it 'should flatten zip archives, when the spec explicitly demands it' do
        options = {
          :http => "#{@fixtures_url}/lib.zip",
          :flatten => true,
        }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('file.txt').should.exist
      end

      it 'should flatten disk images, when the spec explicitly demands it' do
        options = {
          :http => "#{@fixtures_url}/lib.dmg",
          :flatten => true,
        }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('file.txt').should.exist
      end

      it 'moves unpacked contents to parent dir when archive contains only a folder (#727)' do
        downloader = Downloader.for_target(tmp_folder, :http => "#{@fixtures_url}/lib.tar.gz")
        downloader.download
        tmp_folder('file.txt').should.exist
      end

      it 'moves extracted contents to parent dir when archive contains only a folder (#727)' do
        downloader = Downloader.for_target(tmp_folder, :http => "#{@fixtures_url}/lib.dmg")
        downloader.download
        tmp_folder('file.txt').should.exist
      end

      it 'does not move unpacked contents to parent dir when archive contains multiple children' do
        downloader = Downloader.for_target(tmp_folder, :http => "#{@fixtures_url}/lib_multiple.tar.gz")
        downloader.download
        tmp_folder('lib_1/file.txt').should.exist
        tmp_folder('lib_2/file.txt').should.exist
      end

      it 'does not move unpacked contents to parent dir when archive contains multiple children' do
        downloader = Downloader.for_target(tmp_folder, :http => "#{@fixtures_url}/lib_multiple.dmg")
        downloader.download
        tmp_folder('lib_1/file.txt').should.exist
        tmp_folder('lib_2/file.txt').should.exist
      end

      it 'raises if it fails to download' do
        options = { :http => 'broken-link.zip' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.expects(:curl!).with { |command| command.include?('-f') }.raises(DownloaderError)
        should.raise DownloaderError do
          downloader.download
        end
      end

      it 'returns whether it does not support checking for HEAD' do
        options = { :http => 'https://host/file', :type => 'zip' }
        downloader = Downloader.for_target(tmp_folder('checkout'), options)
        downloader.head_supported?.should.be.false
      end

      describe 'concerning archive validation' do
        it 'verifies that the downloaded file matches a sha1 hash' do
          options = {
            :http => "#{@fixtures_url}/lib.zip",
            :sha1 => 'be62f423e2afde57ae7d79ba7bd3443df73e0021',
          }
          downloader = Downloader.for_target(tmp_folder, options)
          should.not.raise do
            downloader.download
          end
        end

        it 'verifies that the downloaded image file matches a sha1 hash' do
          options = {
            :http => "#{@fixtures_url}/lib.dmg",
            :sha1 => 'be62f423e2afde57ae7d79ba7bd3443df73e0021',
          }
          downloader = Downloader.for_target(tmp_folder, options)
          should.not.raise do
            downloader.download
          end
        end

        it 'fails if the sha1 hash does not match' do
          options = {
            :http => "#{@fixtures_url}/lib.zip",
            :sha1 => 'invalid_sha1_hash',
          }
          downloader = Downloader.for_target(tmp_folder, options)
          should.raise DownloaderError do
            downloader.download
          end
        end

        it 'verifies that the downloaded file matches a sha256 hash' do
          options = {
            :http => "#{@fixtures_url}/lib.zip",
            :sha256 => '0a2cb9eca9c468d21d1a9af9031385c5bb7039f1b287836f87cc78b3650e2bdb',
          }
          downloader = Downloader.for_target(tmp_folder, options)
          should.not.raise do
            downloader.download
          end
        end

        it 'fails if the sha256 hash does not match' do
          options = {
            :http => "#{@fixtures_url}/lib.zip",
            :sha256 => 'invalid_sha256_hash',
          }
          downloader = Downloader.for_target(tmp_folder, options)
          should.raise DownloaderError do
            downloader.download
          end
        end
      end

      describe 'concerning archive handling' do
        it 'detects zip files' do
          options = { :http => 'https://host/file.zip' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.send(:type).should == :zip
        end

        it 'detects tar files' do
          options = { :http => 'https://host/file.tar' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.send(:type).should == :tar
        end

        it 'detects tgz files' do
          options = { :http => 'https://host/file.tgz' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.send(:type).should == :tgz
        end

        it 'detects tbz files' do
          options = { :http => 'https://host/file.tbz' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.send(:type).should == :tbz
        end

        it 'detects txz files' do
          options = { :http => 'https://host/file.txz' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.send(:type).should == :txz
        end

        it 'detects dmg files' do
          options = { :http => 'https://host/file.dmg' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.send(:type).should == :dmg
        end

        it 'allows to specify the file type in the sources' do
          options = { :http => 'https://host/file', :type => :zip }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.send(:type).should == :zip
        end

        it 'should download file and extract it with proper type' do
          options = { :http => 'https://host/file.zip' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.expects(:download_file).with(anything)
          downloader.expects(:extract_with_type).with(anything, :zip).at_least_once
          downloader.download
        end

        it 'should raise error when an unsupported file type is detected' do
          options = { :http => 'https://host/file.rar' }
          downloader = Downloader.for_target(tmp_folder, options)
          lambda { downloader.download }.should.raise Http::UnsupportedFileTypeError
        end

        it 'should raise error when an unsupported file type is specified in the options' do
          options = { :http => 'https://host/file', :type => :rar }
          downloader = Downloader.for_target(tmp_folder, options)
          lambda { downloader.download }.should.raise Http::UnsupportedFileTypeError
        end

        it 'detects the file type if specified with a string' do
          options = { :http => 'https://host/file', :type => 'zip' }
          downloader = Downloader.for_target(tmp_folder, options)
          downloader.send(:type).should == :zip
        end
      end
    end
  end
end

require File.expand_path('../spec_helper', __FILE__)
require 'cocoapods-downloader/remote_file'

module Pod
  module Downloader
    class MockRemoteFile < RemoteFile
      def download_file(full_filename)
        uri = URI.parse(url)
        FileUtils.cp(uri.path, full_filename)
      end
    end

    describe 'RemoteFile' do
      before do
        tmp_folder.rmtree if tmp_folder.exist?
        @fixtures_url = 'file://' + fixture('remote_file').to_s
      end

      it 'download file and unzip it' do
        downloader = MockRemoteFile.new(tmp_folder, "#{@fixtures_url}/lib.zip", {})
        downloader.download
        tmp_folder('lib/file.txt').should.exist
        tmp_folder('lib/file.txt').read.strip.should =~ /This is a fixture/
      end

      it 'download file and extract it' do
        downloader = MockRemoteFile.new(tmp_folder, "#{@fixtures_url}/lib.dmg", {})
        downloader.download
        tmp_folder('lib/file.txt').should.exist
        tmp_folder('lib/file.txt').read.strip.should =~ /This is a fixture/
        tmp_folder('file.dmg').should.not.exist
      end

      it 'should download file and unzip it when the target folder name contains quotes or spaces' do
        options = { :http => "#{@fixtures_url}/lib.zip" }
        downloader = Downloader.for_target(tmp_folder_with_quotes, options)
        downloader.download
        tmp_folder_with_quotes('lib/file.txt').should.exist
        tmp_folder_with_quotes('lib/file.txt').read.strip.should =~ /This is a fixture/
      end

      it 'should flatten zip archives, when the spec explicitly demands it' do
        options = { :flatten => true }
        downloader = MockRemoteFile.new(tmp_folder, "#{@fixtures_url}/lib.zip", options)
        downloader.download
        tmp_folder('file.txt').should.exist
        tmp_folder('file.zip').should.not.exist
      end

      it 'should flatten nested zip archives, when the spec explicitly demands it' do
        options = { :flatten => true }
        downloader = MockRemoteFile.new(tmp_folder, "#{@fixtures_url}/nested.zip", options)
        downloader.download
        tmp_folder('file_a.txt').should.exist
        tmp_folder('nested/file_b.txt').should.exist
        tmp_folder('file.zip').should.not.exist
      end

      it 'should flatten disk images, when the spec explicitly demands it' do
        options = { :flatten => true }
        downloader = MockRemoteFile.new(tmp_folder, "#{@fixtures_url}/lib.dmg", options)
        downloader.download
        tmp_folder('file.txt').should.exist
        tmp_folder('file.dmg').should.not.exist
      end

      it 'moves unpacked contents to parent dir when archive contains only a folder (#727)' do
        downloader = MockRemoteFile.new(tmp_folder, "#{@fixtures_url}/lib.tar.gz", {})
        downloader.download
        tmp_folder('file.txt').should.exist
        tmp_folder('file.tgz').should.not.exist
      end

      it 'does not move unpacked contents to parent dir when archive contains multiple children' do
        downloader = MockRemoteFile.new(tmp_folder, "#{@fixtures_url}/lib_multiple.tar.gz", {})
        downloader.download
        tmp_folder('lib_1/file.txt').should.exist
        tmp_folder('lib_2/file.txt').should.exist
      end

      it 'does not move unpacked contents to parent dir when disk image contains multiple children' do
        downloader = MockRemoteFile.new(tmp_folder, "#{@fixtures_url}/lib_multiple.dmg", {})
        downloader.download
        tmp_folder('lib_1/file.txt').should.exist
        tmp_folder('lib_2/file.txt').should.exist
      end

      it 'returns whether it does not support checking for HEAD' do
        options = { :type => 'zip' }
        downloader = MockRemoteFile.new(tmp_folder('checkout'), 'file:///path/to/file', options)
        downloader.head_supported?.should.be.false
      end

      describe 'concerning archive validation' do
        it 'verifies that the downloaded file matches a sha1 hash' do
          options = { :sha1 => 'be62f423e2afde57ae7d79ba7bd3443df73e0021' }
          downloader = MockRemoteFile.new(tmp_folder, "#{@fixtures_url}/lib.zip", options)
          should.not.raise do
            downloader.download
          end
        end

        it 'verifies that the downloaded image file matches a sha1 hash' do
          options = { :sha1 => '3c89800f23ca956672b74c74291ee0eb76c84cdc' }
          downloader = MockRemoteFile.new(tmp_folder, "#{@fixtures_url}/lib.dmg", options)
          should.not.raise do
            downloader.download
          end
        end

        it 'fails if the sha1 hash does not match' do
          options = { :sha1 => 'invalid_sha1_hash' }
          downloader = MockRemoteFile.new(tmp_folder, "#{@fixtures_url}/lib.dmg", options)
          should.raise DownloaderError do
            downloader.download
          end
        end

        it 'verifies that the downloaded file matches a sha256 hash' do
          options = { :sha256 => '0a2cb9eca9c468d21d1a9af9031385c5bb7039f1b287836f87cc78b3650e2bdb' }
          downloader = MockRemoteFile.new(tmp_folder, "#{@fixtures_url}/lib.zip", options)
          should.not.raise do
            downloader.download
          end
        end

        it 'fails if the sha256 hash does not match' do
          options = { :sha256 => 'invalid_sha256_hash' }
          downloader = MockRemoteFile.new(tmp_folder, "#{@fixtures_url}/lib.zip", options)
          should.raise DownloaderError do
            downloader.download
          end
        end
      end

      describe 'concerning archive handling' do
        it 'detects zip files' do
          downloader = MockRemoteFile.new(tmp_folder, 'file:///path/to/file.zip', {})
          downloader.send(:type).should == :zip
        end

        it 'detects tar files' do
          downloader = MockRemoteFile.new(tmp_folder, 'file:///path/to/file.tar', {})
          downloader.send(:type).should == :tar
        end

        it 'detects tgz files' do
          downloader = MockRemoteFile.new(tmp_folder, 'file:///path/to/file.tgz', {})
          downloader.send(:type).should == :tgz
        end

        it 'detects tbz files' do
          downloader = MockRemoteFile.new(tmp_folder, 'file:///path/to/file.tbz', {})
          downloader.send(:type).should == :tbz
        end

        it 'detects txz files' do
          downloader = MockRemoteFile.new(tmp_folder, 'file:///path/to/file.txz', {})
          downloader.send(:type).should == :txz
        end

        it 'detects dmg files' do
          downloader = MockRemoteFile.new(tmp_folder, 'file:///path/to/file.dmg', {})
          downloader.send(:type).should == :dmg
        end

        it 'allows to specify the file type in the sources' do
          options = { :type => :zip }
          downloader = MockRemoteFile.new(tmp_folder, 'file:///path/to/file', options)
          downloader.send(:type).should == :zip
        end

        it 'should download file and extract it with proper type' do
          downloader = MockRemoteFile.new(tmp_folder, 'file:///path/to/file.zip', {})
          downloader.expects(:download_file).with(anything)
          downloader.expects(:extract_with_type).with(anything, :zip).at_least_once
          downloader.download
        end

        it 'should raise error when an unsupported file type is detected' do
          downloader = MockRemoteFile.new(tmp_folder, 'file:///path/to/file.rar', {})
          lambda { downloader.download }.should.raise RemoteFile::UnsupportedFileTypeError
        end

        it 'should raise error when an unsupported file type is specified in the options' do
          options = { :type => :rar }
          downloader = MockRemoteFile.new(tmp_folder, 'file:///path/to/file', options)
          lambda { downloader.download }.should.raise RemoteFile::UnsupportedFileTypeError
        end

        it 'detects the file type if specified with a string' do
          options = { :type => 'zip' }
          downloader = MockRemoteFile.new(tmp_folder, 'file:///path/to/file', options)
          downloader.send(:type).should == :zip
        end
      end
    end
  end
end

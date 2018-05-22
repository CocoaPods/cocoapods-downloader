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
        tmp_folder('file.zip').should.not.exist
      end

      it 'ignores any params in the url' do
        options = { :http => "#{@fixtures_url}/lib.zip?param=value" }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.send(:type).should == :zip
      end

      it 'raises if it fails to download' do
        options = { :http => 'broken-link.zip' }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.expects(:curl!).with { |command| command.include?('-f') }.raises(DownloaderError)
        should.raise DownloaderError do
          downloader.download
        end
      end

      it 'has no preprocessing' do
        options = { :http => 'https://host/file', :type => 'zip' }
        new_options = Downloader.preprocess_options(options)
        new_options.should == options
      end
    end
  end
end

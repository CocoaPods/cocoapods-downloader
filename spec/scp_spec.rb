require File.expand_path('../spec_helper', __FILE__)

module Pod
  module Downloader
    describe 'SCP' do
      before do
        tmp_folder.rmtree if tmp_folder.exist?
        @fixtures_url = fixture('scp').to_s
      end

      it 'download file and unzip it' do
        options = { :scp => "scp://localhost:#{@fixtures_url}/lib.zip" }
        downloader = Downloader.for_target(tmp_folder, options)
        downloader.download
        tmp_folder('lib/file.txt').should.exist
        tmp_folder('lib/file.txt').read.strip.should =~ /This is a fixture/
      end
    end
  end
end

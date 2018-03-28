require File.expand_path('../spec_helper', __FILE__)

module Pod
  module Downloader
    describe Downloader do
      before do
        @subject = Downloader
      end

      describe '::downloader_class_by_key' do
        it 'returns the concrete classes by key' do
          result = @subject.downloader_class_by_key
          result[:git].should == @subject::Git
        end
      end

      describe '::strategy_from_options' do
        it 'returns the strategy' do
          options = {
            :git => '',
          }
          @subject.strategy_from_options(options).should == :git
        end

        it 'returns nil if no strategy could be identified' do
          options = {
            :scm_from_future => '',
          }
          @subject.strategy_from_options(options).should.be.nil
        end

        it 'returns nil if no single strategy could be identified' do
          options = {
            :git => '',
            :svn => '',
          }
          @subject.strategy_from_options(options).should.be.nil
        end
      end

      describe '::for_target' do
        it 'returns the Git downloader' do
          concrete = @subject.for_target(tmp_folder, :git => 'url')
          concrete.class.should == @subject::Git
        end

        it 'returns the Mercurial downloader' do
          concrete = @subject.for_target(tmp_folder, :hg => 'Mercurial')
          concrete.class.should == @subject::Mercurial
        end

        it 'returns the Subversion downloader' do
          concrete = @subject.for_target(tmp_folder, :svn => 'Subversion')
          concrete.class.should == @subject::Subversion
        end

        it 'returns the Http downloader' do
          concrete = @subject.for_target(tmp_folder, :http => 'Http')
          concrete.class.should == @subject::Http
        end

        it 'returns the Scp downloader' do
          concrete = @subject.for_target(tmp_folder, :scp => 'Scp')
          concrete.class.should == @subject::Scp
        end

        it 'returns passes the url to the concrete instance' do
          concrete = @subject.for_target(tmp_folder, :git => 'url')
          concrete.url.should == 'url'
        end

        it 'converts the keys of the options to symbols' do
          options = { 'http' => 'url', 'type' => 'zip' }
          concrete = @subject.for_target(tmp_folder, options)
          concrete.class.should == @subject::Http
          concrete.options.should == { :type => 'zip' }
        end
      end
    end
  end
end

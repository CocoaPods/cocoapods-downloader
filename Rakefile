# Bootstrap
#-----------------------------------------------------------------------------#

desc 'Initializes your working copy to run the specs'
task :bootstrap do
  if system('which bundle')
    title 'Installing gems'
    `bundle install`
  else
    $stderr.puts "\033[0;31m" \
      "[!] Please install the bundler gem manually:\n" \
      "    $ [sudo] gem install bundler" \
      "\e[0m"
    exit 1
  end
end

begin

  require 'bundler/gem_tasks'

  task :default => :spec


  # Spec
  #-----------------------------------------------------------------------------#

  desc 'Run specs'
  task :spec => 'fixtures:unpack_fixture_tarballs' do
    title 'Running Unit Tests'
    files = FileList['spec/**/*_spec.rb'].shuffle.join(' ')
    sh "bundle exec bacon #{files}"

    Rake::Task['rubocop'].invoke if RUBY_VERSION >= '1.9.3'
  end

  # Fixtures
  #-----------------------------------------------------------------------------#

  namespace :fixtures do
    desc 'Rebuild all the fixture tarballs'
    task :rebuild_fixture_tarballs do
      title 'Rebuilding fixtures'
      tarballs = FileList['spec/fixtures/**/*.tar.gz']
      tarballs.each do |tarball|
        basename = File.basename(tarball)
        sh "cd #{File.dirname(tarball)} && rm #{basename} && env COPYFILE_DISABLE=1 tar -zcf #{basename} #{basename[0..-8]}"
      end
    end

    desc 'Unpacks all the fixture tarballs'
    task :unpack_fixture_tarballs do
      title 'Unpacking fixtures'
      tarballs = FileList['spec/fixtures/**/*.tar.gz']
      tarballs.each do |tarball|
        basename = File.basename(tarball)
        Dir.chdir(File.dirname(tarball)) do
          sh "rm -rf #{basename[0..-8]} && tar zxf #{basename}"
        end
      end
    end

    desc 'Removes the stored VCR fixture'
    task :clean_vcr do
      sh 'rm -f spec/fixtures/vcr/tarballs.yml'
    end
  end

  # Travis
  #-----------------------------------------------------------------------------#

  namespace :travis do
    task :setup do
      title 'Configuring Travis'
      sh 'sudo apt-get install subversion'
      sh "env CFLAGS='-I#{rvm_ruby_dir}/include' bundle install --without debugging documentation"
      if ENV['TRAVIS']
        sh "git config --global user.name  'CI'"
        sh "git config --global user.email 'CI@example.com'"
      end
    end
  end

  def rvm_ruby_dir
    @rvm_ruby_dir ||= File.expand_path('../..', `which ruby`.strip)
  end

  # Print options
  #-----------------------------------------------------------------------------#

  desc 'Print the options of the various downloaders'
  task :print_options do
    title 'Downloaders options'
    $LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
    require 'cocoapods-downloader'
    include Pod::Downloader

    Pod::Downloader.downloader_class_by_key.each do |key, klass|
      puts "#{key}: #{klass.options * ', '}"
    end
  end

  #-- Rubocop ----------------------------------------------------------------#

  if RUBY_VERSION >= '1.9.3'
    require 'rubocop/rake_task'
    RuboCop::RakeTask.new
  end

rescue LoadError
  $stderr.puts "\033[0;31m" \
    '[!] Some Rake tasks haven been disabled because the environment' \
    ' couldn’t be loaded. Be sure to run `rake bootstrap` first.' \
    "\e[0m"
end

# Helpers
#-----------------------------------------------------------------------------#

def title(title)
  cyan_title = "\033[0;36m#{title}\033[0m"
  puts
  puts '-' * 80
  puts cyan_title
  puts '-' * 80
  puts
end

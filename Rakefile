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

  #-- Specs ------------------------------------------------------------------#

  desc 'Run specs'
  task :spec => 'fixtures:unpack' do
    title 'Running Unit Tests'
    files = FileList['spec/**/*_spec.rb'].shuffle.join(' ')
    sh "bundle exec bacon #{files}"

    Rake::Task['rubocop'].invoke
  end

  #-- Fixtures ---------------------------------------------------------------#

  namespace :fixtures do
    desc 'Rebuild all the fixture archives'
    task :pack do
      title 'Rebuilding fixtures'
      archives = FileList['spec/fixtures/**/*.{tar.gz,zip}']
      archives.each do |archive|
        puts
        puts archive

        basename = File.basename(archive)
        Dir.chdir(File.dirname(archive)) do
          sh "rm #{basename}"
          if archive.end_with?('_multiple.tar.gz')
            childs = FileList[basename[0..-8] + '/*']
            sh "env COPYFILE_DISABLE=1 tar -zcf #{basename} #{childs.join(' ')}"
          elsif File.extname(archive) == '.gz'
            sh "env COPYFILE_DISABLE=1 tar -zcf #{basename} #{basename[0..-8]}"
          else
            sh "zip -r #{basename} #{basename[0..-5]}"
          end
        end
      end
    end

    desc 'Unpacks all the fixture archives'
    task :unpack do
      title 'Unpacking fixtures'
      archives = FileList['spec/fixtures/**/*.tar.gz']
      archives.each do |archive|
        basename = File.basename(archive)
        Dir.chdir(File.dirname(archive)) do
          sh "rm -rf #{basename[0..-8]} && tar zxf #{basename}"
        end
      end
    end

    desc 'Removes the stored VCR fixture'
    task :clean_vcr do
      sh 'rm -f spec/fixtures/vcr/tarballs.yml'
    end
  end

  #-- Print Options ----------------------------------------------------------#

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

  #-- RuboCop ----------------------------------------------------------------#

  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

rescue LoadError
  $stderr.puts "\033[0;31m" \
    '[!] Some Rake tasks haven been disabled because the environment' \
    ' couldn\'t be loaded. Be sure to run `rake bootstrap` first.' \
    "\e[0m"
  $stderr.puts e.message
  $stderr.puts e.backtrace
  $stderr.puts
end

#-- Helpers ------------------------------------------------------------------#

def title(title)
  cyan_title = "\033[0;36m#{title}\033[0m"
  puts
  puts '-' * 80
  puts cyan_title
  puts '-' * 80
  puts
end

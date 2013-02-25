desc 'Run specs'
task :spec => :unpack_fixture_tarballs do
  files = FileList["spec/**/*_spec.rb"].shuffle.join(' ')
  sh "bacon #{files}"
end

desc "Rebuild all the fixture tarballs"
task :rebuild_fixture_tarballs do
  tarballs = FileList['spec/fixtures/**/*.tar.gz']
  tarballs.each do |tarball|
    basename = File.basename(tarball)
    sh "cd #{File.dirname(tarball)} && rm #{basename} && env COPYFILE_DISABLE=1 tar -zcf #{basename} #{basename[0..-8]}"
  end
end

desc "Unpacks all the fixture tarballs"
task :unpack_fixture_tarballs do
  tarballs = FileList['spec/fixtures/**/*.tar.gz']
  tarballs.each do |tarball|
    basename = File.basename(tarball)
    Dir.chdir(File.dirname(tarball)) do
      sh "rm -rf #{basename[0..-8]} && tar zxf #{basename}"
    end
  end
end

desc "Removes the stored VCR fixture"
task :clean_vcr do
  sh "rm -f spec/fixtures/vcr/tarballs.yml"
end

def rvm_ruby_dir
  @rvm_ruby_dir ||= File.expand_path('../..', `which ruby`.strip)
end

namespace :travis do
  task :setup do
    sh "sudo apt-get install subversion"
    sh "env CFLAGS='-I#{rvm_ruby_dir}/include' bundle install --without debugging documentation"
  end
end

desc 'Generate yardoc'
task :doc do
  sh "rm -rf yardoc"
  sh "yardoc"
end

desc 'Print the options of the various downloaders'
task :print_options do
  $:.unshift File.expand_path('../lib', __FILE__)
  require 'cocoapods-downloader'
  include Pod::Downloader

  result = {}
  Pod::Downloader.downloader_class_by_key.each do |key, klass|
    puts "#{key}: #{klass.options * ', '}"
  end

end

#-----------------------------------------------------------------------------#

namespace :gem do
  def gem_version
    require File.expand_path('../lib/cocoapods-downloader/gem_version', __FILE__)
    Pod::Downloader::VERSION
  end

  def gem_filename
    "cocoapods-downloader-#{gem_version}.gem"
  end

  desc "Build a gem for the current version"
  task :build do
    sh "gem build cocoapods-downloader.gemspec"
  end

  desc "Install a gem version of the current code"
  task :install => :build do
    sh "gem install #{gem_filename}"
  end

  def silent_sh(command)
    output = `#{command} 2>&1`
    unless $?.success?
      puts output
      exit 1
    end
    output
  end

  desc "Run all specs, build and install gem, commit version change, tag version change, and push everything"
  task :release do

    unless ENV['SKIP_CHECKS']
      if `git symbolic-ref HEAD 2>/dev/null`.strip.split('/').last != 'master'
        $stderr.puts "[!] You need to be on the `master' branch in order to be able to do a release."
        exit 1
      end

      if `git tag`.strip.split("\n").include?(gem_version)
        $stderr.puts "[!] A tag for version `#{gem_version}' already exists. Change the version in lib/cocoapods-core/.rb"
        exit 1
      end

      puts "You are about to release `#{gem_version}', is that correct? [y/n]"
      exit if $stdin.gets.strip.downcase != 'y'

      diff_lines = `git diff --name-only`.strip.split("\n")

      if diff_lines.size == 0
        $stderr.puts "[!] Change the version number yourself in lib/cocoapods-core/gem_version.rb"
        exit 1
      end

      diff_lines.delete('Gemfile.lock')
      if diff_lines != ['lib/cocoapods-downloader/gem_version.rb']
        $stderr.puts "[!] Only change the version number in a release commit!"
        $stderr.puts "- " + diff_lines * "\n -"
        exit 1
      end
    end

    require 'date'

    # Ensure that the branches are up to date with the remote
    sh "git pull"

    puts "* Running specs"
    silent_sh('rake spec')

    # puts "* Checking compatibility with the master repo"
    # silent_sh('rake spec:repo')

    tmp = File.expand_path('../tmp', __FILE__)
    tmp_gems = File.join(tmp, 'gems')

    Rake::Task['gem:build'].invoke

    puts "* Testing gem installation (tmp/gems)"
    silent_sh "rm -rf '#{tmp}'"
    silent_sh "gem install --install-dir='#{tmp_gems}' #{gem_filename}"

    # Then release
    sh "git commit lib/cocoapods-downloader/gem_version.rb -m 'Release #{gem_version}'"
    sh "git tag -a #{gem_version} -m 'Release #{gem_version}'"
    sh "git push origin master"
    sh "git push origin --tags"
    sh "gem push #{gem_filename}"

  end
end

#-----------------------------------------------------------------------------#

task :default => :spec


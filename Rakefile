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

task :default => :spec


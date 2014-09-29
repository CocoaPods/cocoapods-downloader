source 'https://rubygems.org'

gemspec

group :development do
  gem 'bacon'
  gem 'kicker'
  gem 'mocha-on-bacon'
  gem 'prettybacon'
  gem 'rake'
  gem 'vcr'
  gem 'webmock', '< 1.9'

  # Ruby 1.8.7
  gem 'mime-types', '< 2.0'

  if RUBY_VERSION >= '1.9.3'
    gem 'rubocop'
    gem 'codeclimate-test-reporter', :require => nil
    gem 'simplecov'
  end
end

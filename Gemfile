source 'https://rubygems.org'

group :development do
  gem 'bacon'
  gem 'kicker'
  gem 'mocha-on-bacon'
  gem 'prettybacon'
  gem 'rake'
  gem 'vcr'
  gem 'webmock', '< 1.9'

  # Ruby 1.8.7
  gem "mime-types", "< 2.0"

  if RUBY_VERSION >= '1.9.3'
    gem 'rubocop'
    gem 'codeclimate-test-reporter', :require => nil

    # Bug: https://github.com/colszowka/simplecov/issues/281
    gem 'simplecov', '0.7.1'
  end
end

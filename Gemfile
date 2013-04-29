source 'https://rubygems.org'

ruby '1.9.3', engine: 'jruby', engine_version: '1.7.2'

gem 'travis-core',        github: 'travis-ci/travis-core'
gem 'travis-support',     github: 'travis-ci/travis-support'
gem 'travis-sidekiqs',    github: 'travis-ci/travis-sidekiqs', require: nil

gem 'hubble',             github: 'roidrage/hubble'
gem 'newrelic_rpm',       '~> 3.3.2'
gem 'sidekiq'
gem 'signature',          '~> 0.1.6'
gem 'sidekiq'
gem 'aws-sdk'

gem 'pusher', '~> 0.11.3'

# can't be removed yet, even though we're on jruby 1.6.7 everywhere
# this is due to Invalid gemspec errors
gem 'rollout',            github: 'jamesgolick/rollout', ref: 'v1.1.0'
gem 'hot_bunnies',        '~> 1.4.0'
gem 'jruby-openssl',      '~> 0.8.8'

# can't be upgraded so far because it starts raising exceptions like:
# https://gist.github.com/drogus/35765d53a3239cee7317
# pinged @nicksieger and @headius about this
gem 'activerecord-jdbcpostgresql-adapter', '1.2.9'

group :test do
  gem 'rspec',            '~> 2.7.0'
  gem 'database_cleaner', '~> 0.7.1'
  gem 'mocha',            '~> 0.10.0'
  gem 'webmock',          '~> 1.8.0'
  gem 'guard'
  gem 'guard-rspec'
end

group :development, :test do
  gem 'micro_migrations', git: 'https://gist.github.com/2087829.git'
end

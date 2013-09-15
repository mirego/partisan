$:.unshift File.expand_path('../lib', __FILE__)

require 'rspec'
require 'sqlite3'

require 'partisan'

# Require our macros and extensions
Dir[File.expand_path('../../spec/support/macros/*.rb', __FILE__)].map(&method(:require))

RSpec.configure do |config|
  # Include our macros
  config.include DatabaseMacros
  config.include ModelMacros
  config.include RailsMacros

  config.before(:each) do
    # Create the SQLite database
    setup_database

    # Run our migration
    run_default_migration

    spawn_model 'Follow', ActiveRecord::Base do
      acts_as_follow
    end
  end

  config.after(:each) do
    # Make sure we remove our test database file
    cleanup_database
  end
end

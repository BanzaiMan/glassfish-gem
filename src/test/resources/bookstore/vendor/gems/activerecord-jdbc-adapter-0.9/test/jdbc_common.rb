require 'rubygems'
# Specify version of activerecord with ENV['AR_VERSION'] if desired
gem 'activerecord', ENV['AR_VERSION'] if ENV['AR_VERSION']
require 'jdbc_adapter'
puts "Using activerecord version #{ActiveRecord::VERSION::STRING}"
puts "Specify version with AR_VERSION=={version} or RUBYLIB={path}"
require 'models/auto_id'
require 'models/entry'
require 'models/add_not_null_column_to_table'
require 'simple'
require 'has_many_through'
require 'test/unit'

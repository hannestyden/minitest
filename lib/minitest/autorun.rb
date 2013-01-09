begin
  require 'rubygems'
  gem 'minitest'
rescue Gem::LoadError
  # do nothing
end

require './lib/minitest/unit'
require './lib/minitest/spec'
require './lib/minitest/mock'

MiniTest::Unit.autorun

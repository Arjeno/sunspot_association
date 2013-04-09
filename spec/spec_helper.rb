require 'active_record'
require 'sunspot_association'
require 'shoulda/matchers'
require 'with_model'
require 'sunspot_test/rspec'

RSpec.configure do |config|
  config.extend WithModel
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                        :database => File.dirname(__FILE__) + "/sunspot_association.sqlite3")

## Test coverage

require 'coveralls'
Coveralls.wear!

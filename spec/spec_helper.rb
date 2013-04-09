require 'active_record'
require 'sunspot_association'
require 'shoulda/matchers'
require 'with_model'

RSpec.configure do |config|
  config.extend WithModel
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                        :database => File.dirname(__FILE__) + "/sunspot_association.sqlite3")

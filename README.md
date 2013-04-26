# sunspot_association [![Gem Version](https://badge.fury.io/rb/sunspot_association.png)](http://badge.fury.io/rb/sunspot_association) [![Build Status](https://secure.travis-ci.org/Arjeno/sunspot_association.png?branch=master)](http://travis-ci.org/Arjeno/sunspot_association) [![Dependency Status](https://gemnasium.com/Arjeno/sunspot_association.png)](https://gemnasium.com/Arjeno/sunspot_association) [![Coverage Status](https://coveralls.io/repos/Arjeno/sunspot_association/badge.png?branch=master)](https://coveralls.io/r/Arjeno/sunspot_association)

Automatic association (re)indexing for your searchable Sunspot models.

## Pure magic

```ruby
class User < ActiveRecord::Base
  belongs_to :company
  searchable do
    associate :text, :company, :name, :phone
  end
end
```

## What it does

The above example will convert to:

```ruby
searchable do
  text :company_name do; company.name end
  text :company_phone do; company.phone end
end
```

It will also hook into `Company` and watch it for changes

## Usage

Add to your Gemfile:

```ruby
gem 'sunspot_association', '~> 0.2.1'
```

## Example

```ruby
class User < ActiveRecord::Base
  belongs_to :company

  searchable do
    associate :text, :company, :name, :phone
    associate :string, :company, :address, :stored => true

    # Converts to:
    # => text :company_name do; company.name end
    # => text :company_phone do; company.phone end
    # => string :company_address, { :stored => true } do; company.address end
  end
end

class Company < ActiveRecord::Base
  has_many :users

  # This configuration is automatically added by the searchable DSL
  # => sunspot_associate :users, :fields => [:name, :phone, :address]
end
```

## License

sunspot_association is distributed under the MIT License, copyright © 2013 Arjen Oosterkamp
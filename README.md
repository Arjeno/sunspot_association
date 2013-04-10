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
gem 'sunspot_association'
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

Copyright (c) 2013 Arjen Oosterkamp

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.## License


# sunspot_association [![Build Status](https://secure.travis-ci.org/Arjeno/sunspot_association.png?branch=master)](http://travis-ci.org/Arjeno/sunspot_association)

Automatically reindex ActiveRecord associations using Sunspot.

## Usage

Add to your Gemfile:

```ruby
gem 'sunspot_association'
```

Add to your model:

```ruby
class Company < ActiveRecord::Base
  sunspot_associate :orders, :fields => :name
end
```

## Example

```ruby
class User < ActiveRecord::Base
  belongs_to :company

  searchable do
    text :company_name { company.try(:name) }
  end
end

class Order < ActiveRecord::Base
  belongs_to :company

  searchable do
    text :company_name { company.try(:name) }
  end
end

class Company < ActiveRecord::Base
  has_many :orders
  has_many :users

  sunspot_associate :orders, :users

  # Or only track changes for the name field
  # => sunspot_associate :orders, :users, :fields => :name
end
```

## License

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
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# My Active Record Lite Version

## Features:
* SQL Object - table_name, parse_all, find, insert, update, save
* Searchable - execute SQL where queries
* Associations - belongs_to, has_many, has_one_through

## To do:
* Write "where" so that it is lazy and stackable. Implement a Relation class.
* Validation methods/validator class.
* has_many :through

## How to use:
* Extract ZIP file of this repo into the project you want to user
* Require: require_relative './MyActiveRecord/arlitev'
* Load your SQLite3 Database through 'DBCONNECTION.open(PATH_TO_YOUR_DB_FILE)'
* Use methods provided in MyActiveRecord for manipulating and querying data.

For example:

```ruby
require 'arlitev'

class Cat < SQLObject
  belongs_to :human, foreign_key: :owner_id
  has_many :cat_toys

  finalize!
end
```

Enjoy!

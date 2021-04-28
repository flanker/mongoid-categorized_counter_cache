# mongoid-categorized_counter_cache

[![Build Status](https://www.travis-ci.com/flanker/mongoid-categorized_counter_cache.svg?branch=master)](https://www.travis-ci.com/flanker/mongoid-categorized_counter_cache)

Enhancement to `counter cache` for `mongoid`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid-categorized_counter_cache'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid-categorized_counter_cache

## Usage

When you have a one-to-many relation using mongoid, you can define a `counter cache` attribute for the relation.

```ruby
class Author
  include Mongoid::Document

  has_many :books
end

class Book
  include Mongoid::Document
  
  belongs_to :author, counter_cache: true
end
```

Then:

```ruby
author = Author.create
author.books.create

author.books_count
# => 1
# returns a cached count of author.books
```

`mongoid-categorized_counter_cache` helps to you cache the count of children documents by given category (any attribute of child document)

```ruby
class Author
  include Mongoid::Document

  has_many :books
end

class Book
  include Mongoid::Document
  include Mongoid::CategorizedCounterCache
  
  field :genre
  
  belongs_to :author, counter_cache: true

  categorized_counter_cache :author do |book|
    book.genre
  end
end
```

Then:

```ruby
author = Author.create
author.books.create genre: 'fiction'
author.books.create genre: 'drama'

author.books_count
# => 2
# returns a cached count of all author.books

author.books_fiction_count
# => 1
# returns a cached count of all author.books which has a fiction genre

author.books_drama_count
# => 1
# returns a cached count of all author.books which has a drama genre
```

[See spec test for more info](spec/mongoid/categorized_counter_cache_spec.rb)

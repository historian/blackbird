# Blackbird

Blackbird aims to remove traditional ActiveRecord migrations and replace it with DataMapper-like automatic migrations mixed with event based data patching.

The major advantage of Blackbird over migrations is that it allows Rails engines to define there own schemas which get automatically loaded in the application. The application remains in full control as it can overwrite an engines schema.

## Installation

### Using Ruby gems

Add the gem to your `Gemfile`

    gem "rails", "3.0.0.beta3"
    gem "blackbird"

### Using git

Add the repo to your `Gemfile`

    gem "blackbird", :git => "git://github.com/fd/blackbird.git"

## Quick Start Guide

Generate a `Post` model without the migration file.

    $ rails g model Post --migration=false

Create a schema file at `app/schemas/posts_schema.rb` with the following contents:

    class PostsSchema < Blackbird::Schema

      table :posts do |t|
        t.string   :title
        t.text     :body

        t.datetime :published_at
        t.timestamps
      end

    end

Then migrate the database to the new schema:

    $ rake db:transition
    --- Creating table posts
     +c title:string
     +c body:text
     +c published_at:datetime
     +c created_at:datetime
     +c updated_at:datetime

Now, let's make some trivial changes:

- add an index to the published_at column
- add an extra column for the tags

and here is the diff:

    --- a/app/schemas/posts_schema.rb
    +++ b/app/schemas/posts_schema.rb
    @@ -4,7 +4,9 @@ class PostsSchema < Blackbird::Schema
         t.string   :title
         t.text     :body

    -    t.datetime :published_at
    +    t.string :tags
    +
    +    t.datetime :published_at, :index => true
         t.timestamps
       end

Migrate the database to the updated schema:

    $ rake db:transition
    --- Constructive changes for posts
     +c tags:string
     +i published_at

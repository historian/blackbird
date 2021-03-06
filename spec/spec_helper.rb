require 'rubygems'

case ENV['RAILS_VERSION']
when '3.0', nil
  gem 'activerecord', '~> 3.0.0'
when '2.3'
  gem 'activerecord', '~> 2.3.0'
else
  gem 'activerecord', ENV['RAILS_VERSION']
end

require 'blackbird'
require 'fileutils'
require 'pp'

puts "Running with ActiveRecord version #{ActiveRecord::VERSION::STRING}"

tmp = File.expand_path('../../tmp', __FILE__)
FileUtils.mkdir_p(tmp)
FileUtils.rm_f(tmp)

ActiveRecord::Base.establish_connection({
  :adapter => 'sqlite3',
  :database => tmp+'/test.db'
})

ActiveRecord::Schema.define do
  create_table "posts", :force => true do |t|
    t.column "title", :string
    t.column "body",  :text
    t.column "published_at", :datetime
  end

  create_table "pages", :force => true do |t|
    t.column "title", :string
    t.column "body",  :string
    t.column "image_id", :integer
  end

  create_table "images", :force => true do |t|
    t.column "caption", :text
    t.column "filename", :string
  end

  create_table "users", :force => true do |t|
    t.column "full_name", :string
  end

  ActiveRecord::Base.connection.execute('INSERT INTO users (id, full_name) VALUES (1, "Simon Menke")')
  ActiveRecord::Base.connection.execute('INSERT INTO users (id, full_name) VALUES (2, "Yves")')
end


def reset_connection
  tmp = File.expand_path('../../tmp', __FILE__)
  FileUtils.rm_f(tmp+'/test_real.db')
  FileUtils.cp(tmp+'/test.db', tmp+'/test_real.db')

  ActiveRecord::Base.establish_connection({
    :adapter => 'sqlite3',
    :database => tmp+'/test_real.db'
  })
end

Blackbird.options[:verbose] = false
Blackbird.options[:processors] = Blackbird::ProcessorList.new
Blackbird.options[:processors].use 'Blackbird::Processors::IndexedColumns'
Blackbird.options[:processors].use 'Blackbird::Processors::NormalDefault'

FRAGMENT_PATHS = (
  Dir.glob(File.expand_path('../fixtures/a/**/*_fragment.rb', __FILE__)) +
  Dir.glob(File.expand_path('../fixtures/b/**/*_fragment.rb', __FILE__)) )
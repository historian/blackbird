require 'rubygems'
require 'shoulda'
require 'transitions'

FileUtils.mkdir_p('tmp')
FileUtils.rm_f('tmp/test.db')

ActiveRecord::Base.establish_connection({
  :adapter => 'sqlite3',
  :database => 'tmp/test.db'
})

ActiveRecord::Schema.define do
  create_table "posts", :force => true do |t|
    t.column "title", :string
    t.column "body",  :text
  end
end

ActiveRecord::Schema.define do
  create_table "pages", :force => true do |t|
    t.column "title", :string
    t.column "body",  :string
    t.column "image_id", :integer
  end
end

ActiveRecord::Schema.define do
  create_table "images", :force => true do |t|
    t.column "caption", :text
    t.column "filename", :string
  end
end

Transitions::Transition.load(File.expand_path('../fixtures/', __FILE__))
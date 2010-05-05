require 'rubygems'
require 'shoulda'
require 'transitions'

class ActiveSupport::TestCase
  def reset_connection
    tmp = File.expand_path('../../tmp', __FILE__)
    FileUtils.mkdir_p(tmp)
    FileUtils.rm_f(tmp+'/test.db')

    ActiveRecord::Base.establish_connection({
      :adapter => 'sqlite3',
      :database => tmp+'/test.db'
    })

    ActiveRecord::Schema.define do
      create_table "posts", :force => true do |t|
        t.column "title", :string
        t.column "body",  :text
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
    end
  end
end

SEARCH_PATHS = [
  File.expand_path('../fixtures/a', __FILE__),
  File.expand_path('../fixtures/b', __FILE__)
]
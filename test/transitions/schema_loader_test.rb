require File.expand_path('../../test_helper', __FILE__)

class Transitions::SchemaLoaderTest < ActiveSupport::TestCase

  setup do
    reset_connection
    @schema = Transitions::Schema::Loader.load
  end

  context "table called 'posts'" do
    setup do
      @table = @schema.tables['posts']
    end

    should "have a table called posts" do
      assert @schema.tables.key?('posts')
    end

    should "have column called 'id'" do
      assert @table.columns.key?('id')
      assert_equal @table.columns['id'].type, :integer
    end

    should "have a primary key called 'id'" do
      assert @table.columns['id'].primary?
      assert_equal @table.primary_key, 'id'
    end

    should "have column called 'body'" do
      assert @table.columns.key?('body')
      assert_equal @table.columns['body'].type, :text
    end

    should "have column called 'title'" do
      assert @table.columns.key?('title')
      assert_equal @table.columns['title'].type, :string
    end

    should "not have column called 'published_at'" do
      assert !@table.columns.key?('published_at')
    end
  end

end
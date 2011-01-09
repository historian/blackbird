require File.expand_path('../../spec_helper', __FILE__)

describe "Transitions::Schema::Loader" do

  reset_connection
  
  before :each do
    @schema = Transitions::Schema::Loader.load
  end

  describe "loaded tables" do

    it "includes a table called 'posts'" do
      @schema.tables.should include('posts')
    end

    it "includes a table called 'pages'" do
      @schema.tables.should include('pages')
    end

    it "includes a table called 'images'" do
      @schema.tables.should include('images')
    end

    it "includes a table called 'users'" do
      @schema.tables.should include('users')
    end
    
  end

  describe "loaded 'posts' table" do
    before do
      @table = @schema.tables['posts']
    end

    it "has 4 columns" do
      @table.should have(4).columns
    end
    
    it "includes a column called 'id' of type :integer" do
      @table.columns.should include('id')
      @table.columns['id'].type.should eql(:integer)
    end

    it "has a primary key called 'id'" do
      @table.columns['id'].should be_primary
      @table.primary_key.should eql('id')
    end

    it "includes a column called 'body' of type :text" do
      @table.columns.should include('body')
      @table.columns['body'].type.should eql(:text)
    end

    it "includes a column called 'title' of type :string" do
      @table.columns.should include('title')
      @table.columns['title'].type.should eql(:string)
    end

    it "includes a column called 'published_at' of type :datetime" do
      @table.columns.should include('published_at')
      @table.columns['published_at'].type.should eql(:datetime)
    end

    it "has 1 index" do
      @table.should have(1).indexes
    end

    it "includes an index called 'index_posts_on_published_at'" do
      @table.indexes.should include('index_posts_on_published_at')
      idx = @table.indexes['index_posts_on_published_at']
      idx.should have(1).columns
      idx.columns.should include('published_at')
    end
  end

end

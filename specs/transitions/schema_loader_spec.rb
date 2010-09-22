require File.expand_path('../../spec_helper', __FILE__)

describe "Transitions::Schema::Loader" do

  reset_connection
  
  before :each do
    @schema = Transitions::Schema::Loader.load
  end

  describe "table called 'posts'" do
    before :each do
      @table = @schema.tables['posts']
    end

    it "have a table called posts" do
      @schema.tables.key?('posts').should be_true
    end

    it "have column called 'id'" do
      @table.columns.key?('id').should be_true
      @table.columns['id'].type.should eql(:integer)
    end

    it "have a primary key called 'id'" do
      @table.columns['id'].should be_primary
      @table.primary_key.should eql('id')
    end

    it "have column called 'body'" do
      @table.columns.key?('body').should be_true
      @table.columns['body'].type.should eql(:text)
    end

    it "have column called 'title'" do
      @table.columns.key?('title').should be_true
      @table.columns['title'].type.should eql(:string)
    end
  end

end

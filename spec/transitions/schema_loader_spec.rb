describe 'Blackbird::Schema::Loader' do
  before { reset_connection }
  
  let(:schema) { Blackbird::Schema::Loader.load }

  it "has a table called posts" do
    schema.tables.should include('posts')
  end

  describe "table called 'posts'" do
    let(:table)   { schema.tables['posts'] }
    let(:columns) { table.columns }

    it "has a column called 'id'" do
      columns.should include('id')
      columns['id'].type.should == :integer
    end

    it "has a primary key called 'id'" do
      columns['id'].should be_primary
      table.primary_key.should == 'id'
    end

    it "has a column called 'body'" do
      columns.should include('body')
      columns['body'].type.should == :text
    end

    it "have column called 'title'" do
      columns.should include('title')
      columns['title'].type.should == :string
    end
  end

end
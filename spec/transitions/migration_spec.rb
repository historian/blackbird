describe 'Blackbird::Transition' do
  before { reset_connection }
  
  let(:transition) { Blackbird::Transition.build(FRAGMENT_PATHS) }

  describe "changes" do
    let(:changes) { transition.changes }

    it "wants to remove :images" do
      changes.old_tables.should == %w( images )
    end

    it "wants to add :comments" do
      changes.new_tables.should == %w( comments )
    end

    it "wants to change :posts and :pages" do
      changes.changed_tables.should == %w( pages posts )
    end

    it "doesn't want to changed :users" do
      changes.unchanged_tables.should == %w( users )
    end

    describe ":posts(table)" do
      let(:table) { transition.changes.table(:posts) }

      it "doesn't want to remove any columns" do
        table.old_columns.should == %w( )
      end

      it "doesn't  want to add any columns" do
        table.new_columns.should == %w( )
      end

      it "doesn't  want to change any columns" do
        table.changed_columns.should == %w( )
      end

      it "wants to keep all columns unchanged" do
        table.unchanged_columns.should == %w( id title body )
      end

    end

    describe ":pages(table)" do
      let(:table) { transition.changes.table(:pages) }

      it "wants to remove :image_id" do
        table.old_columns.should == %w( image_id )
      end

      it "wants to add :published_at" do
        table.new_columns.should == %w( published_at )
      end

      it "wants to change :body" do
        table.changed_columns.should == %w( body )
      end

      it "wants to keep :id and :title unchanged" do
        table.unchanged_columns.should == %w( id title )
      end

    end

  end

  it "builds instructions" do

    migration = transition.migration
    method = transition.fragments[CommentsFragment].method(:set_user_names)

    actual = migration.instructions

    expected = [
      [:create_table, "comments", {:id=>true, :primary_key=>"id"}],
      [:add_column, "comments", "post_id", :integer, {:null=>true}],
      [:add_column, "comments", "user_id", :integer, {:null=>true}],
      [:add_column, "comments", "body", :text, {:null=>true}],
      [:add_column, "comments", "posted_at", :datetime, {:null=>true}],
      [:add_column, "comments", "username", :string, {:null=>true}],
      [:add_column, "pages", "published_at", :datetime, {:null=>true}],
      [:apply, method],
      [:rename_column, "posts", :published_at, :posted_at],
      [:change_column, "pages", "body", :text, {:null=>true}],
      [:remove_column, "pages", "image_id"],
      [:drop_table, "images"],
      [:add_index, "pages", ["title"], {
        :name=>"index_pages_on_title"}],
      [:add_index, "pages", ["published_at"], {
        :name=>"index_pages_on_published_at"}],
      [:add_index, "posts", ["title"], {:unique=>true,
        :name=>"index_posts_on_title"}],
      [:add_index, "posts", ["posted_at"], {
        :name=>"index_posts_on_posted_at"}],
      [:add_index, "comments", ["post_id"], {
        :name=>"index_comments_on_post_id"}],
      [:add_index, "comments", ["user_id"], {
        :name=>"index_comments_on_user_id"}],
      [:add_index, "comments", ["posted_at"], {
        :name=>"index_comments_on_posted_at"}]
    ]
    
    actual.should == expected
  end

  it "runs instructions" do

    transition.run!
    transition.build
    transition.migration.instructions == []

  end

end
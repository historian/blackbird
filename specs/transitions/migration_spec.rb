require File.expand_path('../../spec_helper', __FILE__)

describe "Transitions::Transition" do

  reset_connection
  
  before :each do
    @transition = Transitions::Transition.build(FRAGMENT_PATHS)
  end

  describe "changes" do

    it "wants to remove :images" do
      @transition.changes.should have(1).old_tables
      @transition.changes.old_tables.should include('images')
    end

    it "wants to add :comments" do
      @transition.changes.should have(1).new_tables
      @transition.changes.new_tables.should include('comments')
    end

    it "wants to change :posts and :pages" do
      @transition.changes.should have(2).changed_tables
      @transition.changes.changed_tables.should include('pages', 'posts')
    end

    it "doesn't want to changed :users" do
      @transition.changes.should have(1).unchanged_tables
      @transition.changes.unchanged_tables.should include('users')
    end

    describe ":posts" do

      before { @table = @transition.changes.table(:posts) }

      it "doesn't want to remove any columns" do
        @table.old_columns.should be_empty
      end

      it "doesn't want to add any columns" do
        @table.new_columns.should be_empty
      end

      it "doesn't want to change any columns" do
        @table.changed_columns.should be_empty
      end

      it "wants to keep all columns unchanged" do
        @table.should have(3).unchanged_columns
        @table.unchanged_columns.should include('id', 'title', 'body')
      end

    end

    describe ":pages" do

      before { @table = @transition.changes.table(:pages) }

      it "want to remove :image_id" do
        @table.should have(1).old_columns
        @table.old_columns.should include('image_id')
      end

      it "want to add :published_at" do
        @table.should have(1).new_columns
        @table.new_columns.should include('published_at')
      end

      it "want to change :body" do
        @table.should have(1).changed_columns
        @table.changed_columns.should include('body')
      end

      it "want to keep :id and :title unchanged" do
        @table.should have(2).unchanged_columns
        @table.unchanged_columns.should include('id', 'title')
      end

    end

  end

  it "build instructions" do

    migration = @transition.migration
    method = @transition.fragments[CommentsFragment].method(:set_user_names)

    migration.instructions.should == [
      [:create_table, "comments", {:id=>true, :primary_key=>"id"}],
      [:add_column, "comments", "post_id", :integer, {:null => true}],
      [:add_column, "comments", "user_id", :integer, {:null => true}],
      [:add_column, "comments", "body", :text, {:null => true}],
      [:add_column, "comments", "posted_at", :datetime, {:null => true}],
      [:add_column, "comments", "username", :string, {:null => true}],
      [:add_column, "pages", "published_at", :datetime, {:null => true}],
      [:apply, method],
      [:rename_column, "posts", :published_at, :posted_at],
      [:change_column, "pages", "body", :text, {:null => true}],
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

  end

  it "run instructions" do

    @transition.run!
    @transition.build
    @transition.migration.instructions.should be_empty

  end

end

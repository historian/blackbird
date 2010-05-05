require File.expand_path('../../test_helper', __FILE__)

class Transitions::MigrationTest < ActiveSupport::TestCase

  setup do
    reset_connection
    @transition = Transitions::Transition.build(SEARCH_PATHS)
  end

  context "changes" do

    should "want to remove :images" do
      assert_equal %w( images ), @transition.changes.old_tables
    end

    should "want to add :comments" do
      assert_equal %w( comments ), @transition.changes.new_tables
    end

    should "want to change :posts and :pages" do
      assert_equal %w( pages posts ), @transition.changes.changed_tables
    end

    should "not have unchanged tables" do
      assert_equal %w( ), @transition.changes.unchanged_tables
    end

    context ":posts" do

      setup { @table = @transition.changes.table(:posts) }

      should "not want to remove any columns" do
        assert_equal %w(), @table.old_columns
      end

      should "not want to add any columns" do
        assert_equal %w(), @table.new_columns
      end

      should "not want to change any columns" do
        assert_equal %w(), @table.changed_columns
      end

      should "want to keep all columns unchanged" do
        assert_equal %w( id title body ), @table.unchanged_columns
      end

    end

    context ":pages" do

      setup { @table = @transition.changes.table(:pages) }

      should "want to remove :image_id" do
        assert_equal %w( image_id ), @table.old_columns
      end

      should "want to add :published_at" do
        assert_equal %w( published_at ), @table.new_columns
      end

      should "want to change :body" do
        assert_equal %w( body ), @table.changed_columns
      end

      should "want to keep :id and :title unchanged" do
        assert_equal %w( id title ), @table.unchanged_columns
      end

    end

  end

  should "build instructions" do

    migration = @transition.migration
    assert_equal [
      [:create_table, "comments", {:id=>true, :primary_key=>"id"}],
      [:add_column, "comments", "post_id", :integer, {}],
      [:add_column, "comments", "body", :text, {}],
      [:add_column, "comments", "posted_at", :datetime, {}],
      [:add_index, "comments", ["post_id"], {
        :name=>"index_comments_on_post_id"}],
      [:add_index, "comments", ["posted_at"], {
        :name=>"index_comments_on_posted_at"}],
      [:add_column, "pages", "published_at", :datetime, {}],
      [:add_index, "pages", ["title"], {
        :name=>"index_pages_on_title"}],
      [:add_index, "pages", ["published_at"], {
        :name=>"index_pages_on_published_at"}],
      [:add_index, "posts", ["title"], {:unique=>true,
        :name=>"index_posts_on_title"}],
      [:change_column, "pages", "body", :text, {}],
      [:remove_column, "pages", "image_id"],
      [:drop_table, "images"]
    ],  migration.instructions

  end

  should "run instructions" do

    @transition.run!
    @transition.build
    assert_equal [], @transition.migration.instructions

  end

end
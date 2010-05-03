require File.expand_path('../../test_helper', __FILE__)

class Transitions::MigrationTest < ActiveSupport::TestCase

  setup do
    @future  = Transitions::TransitionRunner.run
    @current = Transitions::SchemaLoader.load
  end

  should "build instructions" do

    migration = Transitions::Migration.build(@current, @future)
    assert_equal migration.instructions, [
      [:create_table, "comments", {:id=>true, :primary_key=>"id"}],
      [:add_column, "comments", "post_id", :integer, {}],
      [:add_column, "comments", "body", :text, {}],
      [:add_column, "comments", "published_at", :datetime, {}],
      [:add_index, "comments", ["post_id"], {
        :name=>"index_comments_on_post_id"}],
      [:add_index, "comments", ["published_at"], {
        :name=>"index_comments_on_published_at"}],
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
    ]

  end

  should "run instructions" do

    Transitions::Migration.run!(@current, @future)
    future    = Transitions::TransitionRunner.run
    current   = Transitions::SchemaLoader.load
    migration = Transitions::Migration.build(current, future)
    assert_equal migration.instructions, []

  end

end
class CommentsFragment < Transitions::Fragment

  table :comments do |t|
    t.remove   :published_at
    t.datetime :posted_at, :index => true
    t.string   :username
  end

  patch "Rename published_at to posted_at in comments" do |p|
    t = p.table(:comments)

    if t.add?(:posted_at) and t.remove?(:published_at)
      t.rename(:published_at, :posted_at)
    end
  end

  patch "Add usernames based on user_ids" do |p|
    t = p.table(:comments)

    if t.add?(:username) and t.exists?(:user_id)
      t.apply :set_user_names
    end
  end

  def set_user_names
    user_names = select_rows %{ SELECT comments.id, users.full_name FROM comments LEFT JOIN users ON users.id = comments.user_id }
    user_names.each do |(id, name)|
      execute %{ UPDATE comments SET username = ? WHERE id = ? }, name, id
    end
  end

end
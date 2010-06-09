class CommentsFragment < Transitions::Fragment

  table :comments do |t|
    t.rename   :published_at, :posted_at
    t.string   :username
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
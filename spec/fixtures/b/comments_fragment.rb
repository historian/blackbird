class CommentsFragment < Blackbird::Fragment

  table :comments do |t|
    t.rename   :published_at, :posted_at
    t.string   :username
  end

  def set_user_names
    user_names = select_rows %{ SELECT comments.id, users.full_name FROM comments LEFT JOIN users ON users.id = comments.user_id }
    user_names.each do |(id, name)|
      execute %{ UPDATE comments SET username = ? WHERE id = ? }, name, id
    end
  end

end
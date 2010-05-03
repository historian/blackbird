class ChangePostsTransition < Transitions::Transition
  def transition

    change_table :posts do |t|
      t.string :title, :unique => true
      t.remove :published_at
    end

  end
end
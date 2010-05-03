class CreatePagesTransition < Transitions::Transition
  def transition

    create_table :pages do |t|
      t.string   :title, :index => true
      t.text     :body
      t.datetime :published_at, :index => true
    end

  end
end
class PagesFragment < Transitions::Fragment

  table :pages do
    scope :index => true do
      string   :title
      datetime :published_at
    end
    text :body
  end

end

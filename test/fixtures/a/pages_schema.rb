class PagesSchema < Transitions::Schema

  table :pages do |t|
    t.string   :title, :index => true
    t.text     :body
    t.datetime :published_at, :index => true
  end

end
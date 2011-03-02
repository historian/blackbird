class Blackbird::Fragments::SchemaMigrationsFragment < Blackbird::Fragment

  table :schema_migrations, :id => false do |t|
    t.string :version
    t.index :version, :unique => true, :name => 'unique_schema_migrations'
  end

end
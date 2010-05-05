class Transitions::Transition

  def run!(*search_paths)
    build(search_paths).run!
  end

  def self.build(*search_paths)
    new(search_paths).build
  end

  attr_reader :search_paths, :current, :future, :changes, :migration

  def initialize(*search_paths)
    @search_paths = search_paths.flatten.uniq
  end

  def build
    load_schema_definitions
    load_current
    build_future
    analyze_changes
    build_migration

    self
  end

  def run!
    connection = ActiveRecord::Base.connection
    connection.transaction do

      @migration.instructions.each do |instruction|
        connection.__send__(*instruction)
      end

    end

    self
  end

private

  def load_schema_definitions
    @search_paths.each do |search_path|
      search_path = File.expand_path(search_path)
      Dir.glob(File.join(search_path, '**/*_schema.rb')).each do |path|
        require path
      end
    end
  end

  def load_current
    @current = Transitions::SchemaLoader.load
  end

  def build_future
    @future = Transitions::SchemaDefinition.new
    builder = Transitions::SchemaBuilder.new(@future)
    Transitions::Schema.subclasses.each do |schema|
      schema.new.apply(builder)
    end
  end

  def analyze_changes
    @changes = Transitions::SchemaChanges.analyze!(@current, @future)
  end

  def build_migration
    @migration = Transitions::Migration.build(@current, @future, @changes)
  end

end
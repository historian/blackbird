class Transitions::Transition

  def self.run!(*schema_files)
    build(schema_files).run!
  end

  def self.build(*schema_files)
    new(schema_files).build
  end

  attr_reader :schema_files, :current, :future, :changes, :migration, :schemas

  def initialize(*schema_files)
    @schema_files = schema_files.flatten.uniq.compact
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
        case instruction.first
        when :apply
          instruction.last.call
        when :log
          puts instruction.last if Transitions.options[:verbose]
        else
          connection.__send__(*instruction)
        end
      end

    end

    self
  end

private

  def load_schema_definitions
    @schema_files.each do |path|
      require path
    end
  end

  def load_current
    @current = Transitions::SchemaLoader.load
  end

  def build_future
    @future = Transitions::SchemaDefinition.new
    @schemas = ActiveSupport::OrderedHash.new
    builder = Transitions::SchemaBuilder.new(@future)
    Transitions::Schema.subclasses.each do |schema|
      schema = schema.new
      @schemas[schema.class] = schema
      schema.apply(builder)
    end
  end

  def analyze_changes
    @changes = Transitions::SchemaChanges.analyze!(@current, @future)
  end

  def build_migration
    @migration = Transitions::Migration.build(@current, @future, @changes)
  end

end
# Blackbird::Transition is the coordinator of the transition process
class Blackbird::Transition

  def self.run!(*fragment_files)
    build(fragment_files).run!
  end

  def self.build(*fragment_files)
    new(fragment_files).build
  end

  attr_reader :fragment_files, :current, :future, :changes, :migration, :fragments

  def initialize(*fragment_files)
    @fragment_files = fragment_files.flatten.uniq.compact
  end

  def build
    load_fragments
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
          puts instruction.last if Blackbird.options[:verbose]
        when :create_table
          connection.__send__(*instruction) {}
        else
          connection.__send__(*instruction)
        end
      end

    end

    self
  end

private

  def load_fragments
    @fragment_files.each do |path|
      require path
    end
  end

  def load_current
    @current = Blackbird::Schema::Loader.load
  end

  def build_future
    @future = Blackbird::Schema.new
    @fragments = ActiveSupport::OrderedHash.new
    builder = Blackbird::Schema::Builder.new(@future)
    Blackbird::Fragment.subclasses.each do |fragment|
      fragment = fragment.new
      @fragments[fragment.class] = fragment
      fragment.apply(builder)
    end

    Blackbird.options[:processors].build.each do |processor|
      @future.process processor
    end
  end

  def analyze_changes
    @changes = Blackbird::Schema::Changes.analyze!(@current, @future)
  end

  def build_migration
    @migration = Blackbird::Migration.build(@current, @future, @changes)
  end

end

class Transitions::Transition

  def self.transitions
    @transitions ||= []
  end

  def self.inherited(subclass)
    subclass.version = Thread.current[:transitions_version]
    Transitions::Transition.transitions.push(subclass)
    subclass.extend InheritanceBlocker
  end

  module InheritanceBlocker
    def inherited(subclass)
      raise "Cannot inherit form Transitions::Transition subclass."
    end
  end

  def self.load(*search_paths)
    search_paths = search_paths.flatten.compact
    search_paths.collect! do |path|
      File.expand_path(path)
    end
    search_paths.uniq!
    search_paths.each do |path|
      Dir.entries(path).each do |name|
        next unless name =~ /^(\d+)_.+\.rb$/
        Thread.current[:transitions_version] = $1.to_i
        Kernel.load File.join(path, name)
      end
    end
    true
  end

  class << self
    attr_accessor :version
  end

  attr_reader :version

  def initialize(version=self.class.version)
    @version = version
  end

  def transition
    # needs to be implemented in subclasses
  end

  def run(schema)
    @schema = schema
    transition
    @schema
  end

private

  def create_table(name, options={}, &block)
    @schema.create_table(name, options={}, &block)
  end

  def change_table(name, &block)
    @schema.change_table(name, &block)
  end

  def rename_table(old_name, new_name)
    @schema.rename_table(old_name, new_name)
  end

  def drop_table(name)
    @schema.drop_table(name)
  end

end
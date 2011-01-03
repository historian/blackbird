class Transitions::Fragment

  def self.subclasses
    @subclasses ||= []
  end

  def self.inherited(subclass)
    Transitions::Fragment.subclasses.push(subclass)
    subclass.extend InheritanceBlocker
  end

  def self.instructions
    @instructions ||= []
  end

  def self.table(name, options={}, &block)
    self.instructions << [:table, name, options, block]
  end

  def self.patch(name, options={}, &block)
    self.instructions << [:patch, name, options, block]
  end

  def initialize
    @instructions = self.class.instructions.dup
  end

  def apply(builder)
    @instructions.each do |instruction|
      instruction = instruction.dup
      instruction[1,0] = self
      block = (Proc === instruction.last ? instruction.pop : nil)
      builder.__send__(*instruction, &block)
    end
  end

private

  def connection
    ActiveRecord::Base.connection
  end

  %w( select_values select_value select_rows select_all execute ).each do |m|
    define_method(m) do |sql_pattern, *args|
      sql = sql = sql_pattern.gsub('?') do
        connection.quote(arguments.shift)
      end
      connection.__send__(m, sql)
    end
  end

  module InheritanceBlocker
    def inherited(base)
      raise "#{base} cannot inherit from non abstract fragment #{self}"
    end
  end

end
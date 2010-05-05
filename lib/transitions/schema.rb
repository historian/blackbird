class Transitions::Schema

  def self.subclasses
    @subclasses ||= []
  end

  def self.inherited(subclass)
    Transitions::Schema.subclasses.push(subclass)
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
      block = nil
      if Proc === instruction.last
        block, instruction = instruction.last, instruction[0..-2]
      end
      builder.__send__(*instruction, &block)
    end
  end

end
class Transitions::Schema
  
  def self.instructions
    @instructions ||= []
  end
  
  def self.table(name, options={}, &block)
    self.instructions << [:table, options, block]
  end
  
  def self.patch(name, options={}, &block)
    self.instructions << [:patch, options, block]
  end
  
  def initialize
    @instructions = self.class.instructions.dup
  end
  
  def apply(schema_definition)
    @instructions.each do |instruction|
      schema_definition.__send__(*instruction)
    end
  end
  
end
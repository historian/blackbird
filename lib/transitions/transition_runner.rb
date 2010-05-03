class Transitions::TransitionRunner

  def self.run
    transitions = Transitions::Transition.transitions
    transitions = transitions.collect do |klass|
      klass.new
    end
    new(transitions).run
  end

  def initialize(transitions)
    @transitions = transitions
    @transitions.sort! { |a, b| a.version <=> b.version }
  end

  def run
    schema = Transitions::SchemaDefinition.new
    @transitions.inject(schema) do |schema, transition|
      transition.run(schema)
    end
  end

end
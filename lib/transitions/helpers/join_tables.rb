module Transitions::Helpers::JoinTables

  def join(*args, &block)

    tables  = []
    columns = []

    while arg = args.shift
      case arg
      when String, Symbol
        tables  << arg.to_s
        columns << "#{arg.to_s.singularize}_id"
        
      when Array
        tables  << arg[0].to_s
        columns << arg[1].to_s
        
      when Hash
        args = arg.to_ary + args

      else
        raise ArgumentError
        
      end  
    end

    name = tables.dup.sort.join('_')
    
    table name, :id => false do |t|

      columns.each do |column|
        t.integer column
      end

      if block
        if block.arity == 1
          block.call(t)
        else
          t.instance_eval(&block)
        end
      end
      
    end

    self
  end

  Transitions::Schema::Builder.send(:include, self)
  
end

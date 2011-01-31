class Blackbird::ProcessorList < Array

  def use(processor, *args, &block)
    push([processor.to_s, args, block])
    self
  end

  def insert_before(other, processor, *args, &block)
    idx = index { |p| p.first == other.to_s }
    if idx
      insert(idx, [processor.to_s, args, block])
    else
      unshift([processor.to_s, args, block])
    end
    self
  end

  def insert_after(other, processor, *args, &block)
    idx = index { |p| p.first == other.to_s }
    if idx
      insert(idx + 1, [processor.to_s, args, block])
    else
      push([processor.to_s, args, block])
    end
    self
  end

  def delete(name)
    idx = index { |p| p.first == other.to_s }
    if idx
      delete_at(idx)
    end
  end

  def build
    collect do |(klassname, args, block)|
      klassname.constantize.new(*args, &block)
    end
  end
  
end

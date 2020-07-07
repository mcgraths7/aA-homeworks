class Stack
  attr_reader :stack
  def initialize
    @stack = []
  end

  def push(element)
    @stack.push(element)
  end

  def pop
    @stack.pop
  end

  def peek
    @stack[0]
  end
end


s = Stack.new
s.push(5)
s.push(4)
s.pop
s.push(6)
s.push(1)
s.pop
s.pop
# Should be => [5]
p s.peek
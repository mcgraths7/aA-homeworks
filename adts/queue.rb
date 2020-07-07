class Queue
  def initialize
    @queue = []
  end
  
  def enqueue(element)
    @queue.unshift(element)
  end

  def dequeue
    @queue.pop
  end

  def peek
    @queue[0]
  end
end

q = Queue.new
q.enqueue(5)
q.enqueue(4)
q.dequeue
q.enqueue(12)
q.dequeue
p q # => [12]
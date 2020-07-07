class Map
  def initialize
    @map = Array.new([])
  end

  def get(key)
    @map.each do |kv|
      return kv if kv[0] == key
    end
    return nil
  end

  def set(key, value)
    @map.each do |kv|
      if kv[0] == key
        kv[1] = value
        return kv
      end
    end
    @map.push([key, value])
  end

  def delete(key)
    @map = @map.reject do |kv| 
      kv[0] == key
    end
  end
end

m = Map.new
m.set('a', 'A')
m.set('b', 'B')
m.set('c', 'C')
p m.get('c')
p m.delete('c')
p m
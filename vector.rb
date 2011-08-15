require 'dimension'
require 'util'
class Vector < Array
  def initialize
    super($dimension, 0.0).to_v
  end
  def validate
    unless self.size == $dimension && self.all?{|v| v.kind_of?(Numeric) }
      raise "self = #{self} not #{$dimension} dimensional vector"
    end
    self
  end
  def +(a)
    zip(a).map {|a,b| a + b}.to_v
  end
  def -(a)
    zip(a).map {|a,b| a - b}.to_v
  end
  def -@
    map{|x| -x}.to_v
  end
  def +@
    self
  end
  def *(a)
    if a.kind_of?(Vector) # inner product
      zip(a).map {|a,b| a*b}.inject(&:+)
    else
      map{|v| v*a}.to_v # scalar product
    end
  end
  def /(a)
    if a.kind_of?(Vector)
      raise "No division defined for two vectors"
    else
      map{|v| v/a}.to_v # scalar quotient
    end
  end
  def coerce(k)
    [VectorProxy.new(k), self]
  end
  def squared
    self*self
  end
  def abs
    Math.sqrt(squared)
  end
end
class VectorProxy
  def initialize(v)
    @value = v
  end
  def *(v)
    v * @value
  end
end
class Array
  def to_v
    Vector[*self]
  end
end

def Vector.tailored_random(maxlen)
  loop do
    v = $dimension.times.collect { Math::frand(-maxlen, maxlen) }.to_v
    return v if yield v
  end
end

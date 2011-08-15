require 'yaml'

class Object
  def serialize
    YAML.dump(self)
  end
end
class String
  def deserialize
    YAML.load(self)
  end
end

module Writable
  def write(io)
    io.puts serialize
  end
end
module Readable
  def self.included(klass)
    def klass.read(io)
      obj = io.read.deserialize
      if obj.class != self
        raise "#{obj.class.to_s} is not what was expected: #{self.to_s}"
      end
      obj
    end
    def klass.read_stream(io)
      YAML.load_documents(io) do |obj|
        if obj.class != self
          raise "#{obj.class.to_s} is not what was expected: #{self.to_s}"
        end
        yield obj
      end
    end
  end
end

module Math
  def frand(low, high)
    low + rand * (high - low)
  end
  module_function :frand
end

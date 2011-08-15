#!/usr/bin/env ruby
require 'body'
require 'serialize'
require 'plotter'
require 'option'

def mkcold(n)
  nb = Body.new
  n.times do
    nb.add_child!(
      Body.new(
      1.0/n,
      Vector.tailored_random(1.0) {|v| v.abs <= 1.0 },
      Vector.new
    ))
  end
  nb
end

config = init_option_info ARGV, <<-END
Description: Generate cold collapse
Options:
  - Short name:       -n N
    Long name:        --n_particles N
    Variable name:    n
    Value type:       Integer
    Default value:    1
    Description:      Number of particles

  - Short name:       -s SEED
    Long name:        --seed SEED
    Variable name:    seed
    Value type:       Integer
    Description:      pseudorandom number seed given
END

srand config.seed if config.seed
dimension(3) do
  nb = mkcold(config.n)
  nb.write(STDOUT)
end

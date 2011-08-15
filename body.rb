require 'util'
require 'vector'
require 'serialize'
require 'plotter'

class Body
  include Math
  include Writable
  include Readable
  attr_accessor :mass, :pos, :vel
  attr_accessor :time, :body

  def initialize(mass = 0, pos = Vector.new, vel = Vector.new, time = 0.0)
    @mass, @pos, @vel = mass, pos, vel
    @time = time
    @body = []
  end

  def add_child!(b)
    @mass += b.mass
    @body << b
  end
  def shift!(pos, vel = Vector.new)
    @pos += pos
    @vel += vel
    self
  end

  def Body.combine(a, b)
    com_mass = a.mass + b.mass
    com_pos  = (a.mass*a.pos + b.mass*b.pos)/com_mass
    com_vel  = (a.mass*a.vel + b.mass*b.vel)/com_mass

    a.body.each {|x| x.shift!(a.pos - com_pos, a.vel - com_vel) }
    b.body.each {|x| x.shift!(b.pos - com_pos, b.vel - com_vel) }

    nb = Body.new(com_mass, com_pos, com_vel)
    nb.body = a.body + b.body
    nb
  end

  def pair_collision_time_scale_squared(a, b)
      r2 = (a.pos - b.pos).squared
      v2 = (a.vel - b.vel).squared
      motion_estimate_squared = r2 / v2 # [distance]^2/[velocity]^2 = [time]^2
      acc = (a.mass + b.mass)/r2
      free_fall_estimate_squared = sqrt(r2)/acc # [distance]/[acceleration] = [time]^2
      [motion_estimate_squared, free_fall_estimate_squared].min
  end
  private :pair_collision_time_scale_squared

  def collision_time_scale
    sqrt(@body.combination(2).map {|a, b|
      pair_collision_time_scale_squared(a, b)}.min)
  end

  def external_ekin # kinetic energy
    0.5*@mass*(@vel.squared)
  end

  def external_epot(body_array, eps = 0.0) # potential energy
    p = 0
    body_array.each do |b|
      unless b == self
        r2 = (b.pos - @pos).squared
        p += -@mass*b.mass/sqrt(r2 + eps*eps)
      end
    end
    p
  end

  def internal_ekin # kinetic energy
    @body.map{|b| b.external_ekin}.inject(&:+)
  end

  def internal_epot(eps = 0.0) # potential energy
    @body.map{|b| b.external_epot(@body, eps)}.inject(&:+)/2 # pairwise potentials were counted twice
  end
end

class NBodyPlotter
  def initialize(plotter)
    @plotter = plotter
  end
  def display(nbody)
    @plotter.scene do
      nbody.body.each do |b|
        point(b.pos)
      end
    end
  end
end

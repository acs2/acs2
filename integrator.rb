require 'body'
class Integrator
  include Math
  def initialize(info, observer)
    @info = info
    @observer = observer
  end
  def evolve(nb)
    @observer.setup(nb)

    t_end = nb.time + @info.dt_end

    while nb.time < t_end
      dt = @info.dt_param * (@info.fixed_timestep_flag ? @info.eps : nb.collision_time_scale)
      if @info.exact_time_flag and nb.time + dt > t_out
        dt = t_out - nb.time
      end
      nb.body.each do |b|
        calc(b, nb, dt)
      end
      nb.time += dt
      @observer.write_diagnostics(nb)
      @observer.write(nb)
    end
  end
  def acc(b, nb)
    a = Vector.new # null vector
    nb.body.each do |x|
      unless b == x
        r = x.pos - b.pos
        r2 = r*r + @info.eps**2
        r3 = r2*sqrt(r2)
        a += r*(x.mass/r3)
      end
    end
    a
  end    
  def jerk(b, nb)
    j = Vector.new # null vector
    nb.body.each do |x|
      unless x == b
        r = x.pos - b.pos
        r2 = r*r
        r3 = r2*sqrt(r2)
        v = x.vel - b.vel
        j += (v-r*(3*(r*v)/r2))*(x.mass/r3)
      end
    end
    j
  end    

  protected :acc, :jerk
end

class Forward < Integrator
  def calc(b, nb, dt)
    old_acc = acc(b, nb)
    b.pos += b.vel*dt
    b.vel += old_acc*dt
  end
end
class Rk2 < Integrator
  def calc(b, nb, dt)
    old_pos = b.pos
    half_vel = b.vel + acc(b, nb)*0.5*dt
    b.pos += b.vel*0.5*dt
    b.vel += acc(b, nb)*dt
    b.pos = old_pos + half_vel*dt
  end
end
class Rk4 < Integrator
  def calc(b, nb, dt)
    old_pos = b.pos
    a0 = acc(b, nb)
    b.pos = old_pos + b.vel*0.5*dt + a0*0.125*dt*dt
    a1 = acc(b, nb)
    b.pos = old_pos + b.vel*dt + a1*0.5*dt*dt
    a2 = acc(b, nb)
    b.pos = old_pos + b.vel*dt + (a0+a1*2)*(1/6.0)*dt*dt
    b.vel += (a0+a1*4+a2)*(1/6.0)*dt
  end
end
class Leapfrog < Integrator
  def calc(b, nb, dt)
    b.vel += acc(b, nb)*0.5*dt
    b.pos += b.vel*dt
    b.vel += acc(b, nb)*0.5*dt
  end
end
class Hermite < Integrator
  def calc(b, nb, dt)
    old_pos = b.pos
    old_vel = b.vel
    old_acc = acc(b, nb)
    old_jerk = jerk(ba)
    b.pos += b.vel*dt + old_acc*(dt*dt/2.0) + old_jerk*(dt*dt*dt/6.0)
    b.vel += old_acc*dt + old_jerk*(dt*dt/2.0)
    b.vel = old_vel + (old_acc + acc(b, nb))*(dt/2.0) +
               (old_jerk - jerk(ba))*(dt*dt/12.0)
    b.pos = old_pos + (old_vel + vel)*(dt/2.0) + (old_acc - acc(b, nb))*(dt*dt/12.0)
  end
end

def make_integrator(info, observer)
  {
    :forward => Forward,
    :rk2 => Rk2,
    :rk4 => Rk4,
    :leapfrog => Leapfrog,
    :hermite => Hermite
  }[info.method].new(info, observer)
end

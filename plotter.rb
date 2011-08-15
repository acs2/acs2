class Plotter
end

class Gnuplot < Plotter
  def initialize
    @count = 1
    @io = IO.popen('gnuplot', 'w')
    @point_type = 3

    @io.puts("set terminal png size 1024,768")
    @io.puts("set xrange [-4.0:4.0]")
    @io.puts("set yrange [-4.0:4.0]")
    @io.puts("set zrange [-4.0:4.0]")
  end
  def scene(&blk)
    @io.printf("set output \"galaxy_collision%04d.png\"\n", @count)
    @count += 1
    @io.puts("splot \"-\" pt #{@point_type}")
    self.instance_eval(&blk)
    @io.puts("end")
    @io.flush
  end
  def point(pos)
    @io.puts(pos.map(&:to_s).join(" ")) 
  end
end

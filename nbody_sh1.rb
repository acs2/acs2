#!/usr/bin/env ruby
require 'option'
require 'body'
require 'integrator'

option_info = init_option_info ARGV, <<-END
Options:
  - Short name:     -g METHOD
    Long name:      --integration_method METHOD
    Variable name:  method
    Value type:     String
    Default value:  hermite
    Description:    Integration method

  - Short name:     -c ETA
    Long name:      --step_size_control ETA
    Variable name:  dt_param
    Value type:     Float
    Default value:  0.01
    Description:    Parameter to determine time step size

  - Short name:     -d DIA
    Long name:      --diagnostics_interval DIA
    Variable name:  dt_dia
    Value type:     Float
    Default value:  1.0
    Description:    Interval between diagnostics output

  - Short name:     -o OUT
    Long name:      --output_interval OUT
    Variable name:  dt_out
    Value type:     Float
    Default value:  1.0
    Description:    Time interval between snapshot output

  - Short name:     -t END
    Long name:      --duration END
    Variable name:  dt_end
    Value type:     Float
    Default value:  10.0
    Description:    Duration of the integration

  - Long name:      --exact_time
    Variable name:  exact_time_flag
    Description:    Force all outputs to occur at the exact times

  - Long name:      --init_out
    Variable name:  init_out_flag
    Description:    Output the initial snapshot

  - Short name:     -e EPS
    Long name:      --softening EPS
    Variable name:  eps
    Value type:     Float
    Default value:  0.0
    Description:    Softening parameter

  - Short name:     -f
    Long name:      --fixed_timestep
    Variable name:  fixed_timestep_flag
    Description:    Fixed timestep
END

option_info.method = option_info.method.intern # FIXME: dirty code
option_info.fixed_timestep_flag = true if option_info.method == :leapfrog

class BodyObserver
  def initialize(option_info)
    @info = option_info
  end
  def setup(nb)
    @e0 = nb.internal_ekin + nb.internal_epot(@info.eps)
    @t_dia = nb.time + @info.dt_dia
    @t_out = nb.time + @info.dt_out
    @nsteps = 0

    output_diagnostics(nb)
    nb.write(STDOUT) if @info.init_out_flag
  end
  def write(nb)
    if nb.time >= @t_out - 1.0/1e30
      nb.write(STDOUT)
      @t_out += @info.dt_out
    end
  end
  def write_diagnostics(nb)
    if nb.time >= @t_dia
      output_diagnostics(nb)
      @t_dia += @info.dt_dia
    end
  end
  def output_diagnostics(nb)
    ekin, epot = nb.internal_ekin, nb.internal_epot(@info.eps)
    etot = ekin + epot
    STDERR.print <<END
at time t = #{format("%g", nb.time)}, after #{@nsteps} steps :
E_kin = #{format("%.3g", ekin)} ,\
E_pot =  #{format("%.3g", epot)} ,\
E_tot = #{format("%.3g", etot)}
           E_tot - E_init = #{format("%.3g", etot - @e0)}
(E_tot - E_init) / E_init = #{format("%.3g", (etot - @e0)/@e0 )}
END
  end
end

dimension(3) do
  nb = Body.read(STDIN)
  observer = BodyObserver.new(option_info)
  integrator = make_integrator(option_info, observer)
  integrator.evolve(nb)
end

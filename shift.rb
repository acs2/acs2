#!/usr/bin/env ruby
require 'body'
require 'option'

dimension(3) do
  option_info = init_option_info ARGV, <<-END
  Options:
    - Short name:     -r DPOS
      Long name:      --position_shift DPOS
      Variable name:  position_shift
      Value type:     Vector
      Default value:  [0, 0, 0]
      Description:    Shift in position by [x,y,z]

    - Short name:     -v DVEL
      Long name:      --velocity_shift DVEL
      Variable name:  velocity_shift
      Value type:     Vector
      Default value:  [0, 0, 0]
      Description:    Shift in velocity by [x,y,z]
  END

  nb = Body.read(STDIN)
  nb.shift!(
      option_info.position_shift.to_v,
      option_info.velocity_shift.to_v
  ).write(STDOUT)
end

#!/usr/bin/env ruby
require 'body'

plotter = NBodyPlotter.new(Gnuplot.new)
Body.read_stream(STDIN) do |body|
  plotter.display(body)
  sleep 1
end

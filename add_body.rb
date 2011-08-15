#!/usr/bin/env ruby
require 'body'

dimension(3) do
  body = Body.new
  YAML.load_documents(STDIN) do |b|
      body = Body.combine(body, b)
  end
  body.write(STDOUT)
end

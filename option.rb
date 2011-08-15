require 'vector'
require 'optparse'
require 'yaml'

module OptionInfo
  def setup_summary(parser, desc)
    parser.banner = desc["Description"] if desc["Description"]
    parser.banner += "\n" + desc["Long description"] if desc["Long description"]
  end
  def setup_options(parser, opts)
    names = opts.map {|e| e["Variable name"].intern}
    inits = opts.map {|e| e["Default value"]}
    info = Struct.new(*names).new(*inits)
    opts.each do |ent|
      name = ent["Variable name"].intern
      args = []
      args << ent["Short name"] if ent["Short name"]
      args << ent["Long name"] if ent["Long name"]
      args << eval(ent["Value type"]) if ent["Value type"]
      args << ent["Description"] if ent["Description"]
      parser.on(*args) {|v| info[name] = v}
    end
    info
  end
end

OptionParser.accept(Vector) do |str,|
  begin
    eval(str).to_v.validate if str
  rescue
    raise OptionParser::InvalidArgument, str
  end
end

def init_option_info(argv, desc)
  include OptionInfo
  parser = OptionParser.new
  desc = YAML.load(desc)
  setup_summary(parser, desc)
  if desc["Options"]
    info = setup_options(parser, desc["Options"])
  end
  parser.parse!(argv)
  info
end

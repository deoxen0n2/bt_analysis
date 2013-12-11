# The MIT License (MIT)
# 
# Copyright (c) 2013 Sarun S.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'bencode'
require 'optparse'
require 'yaml'

options = {}
options[:format] = nil
options[:silence] = false

def validate_options(options)
  if options[:format] && !options[:output]
    raise "A format option must be used along with an output option"
  end
end

# default format
options[:format] = "yaml"

ifile_name = ARGV.shift # Metainfo file name must be the first cli argument.

OptionParser.new do |opts|
  
  # Option to output file.
  opts.on("-o", "--output FILE", "Output to a file") do |val|
    options[:output] = val
  end

  # Option to format the output file.
  opts.on("-f", "--format FORMAT", ["json", "yaml"],
          "Set output format") do |val|
    options[:format] = val
  end

  # Option to switch to silence mode.
  opts.on("-q", "--[no-]quiet", "Switch to silence mode") do |val|
    options[:silence] = val
  end
end.parse!

validate_options(options)

# Actual program.
# Read Metainfo file and convert pieces from byte string format to hex string
# format.
metainfo_str = File.read(ifile_name)
metainfo_hash = BEncode.load(metainfo_str)

piece_hexs = metainfo_hash["info"]["pieces"].unpack("H*")[0].scan(/#{"."*40}/)
metainfo_hash["info"]["pieces"] = piece_hexs
puts metainfo_hash.to_yaml unless options[:silence]

if ofile_name = options[:output]
  if options[:format] == "yaml"
    File.open(ofile_name, 'w') do |f|
      f.puts metainfo_hash.to_yaml
    end
  else
    raise "Current version only supports output to YAML format"
  end
end

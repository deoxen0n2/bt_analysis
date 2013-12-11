str = File.read(ARGV[0])

n = ARGV[2].to_i

File.open(ARGV[1], 'w') do |f|
   n.times { f.puts str }
end

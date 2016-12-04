#!/usr/bin/env ruby

require 'gnuplot'

if ARGV.size != 2
    puts "Usage: ./graph.rb probablities.txt outputDir"
    exit 1
end

def plot(outputDir, filename)

    data = File.read(filename).split("\n")
    newFilename = "#{File.split(filename).last.split(".").first}-plot"
    outputFile = File.join(outputDir, newFilename)
File.open("#{outputFile}.dat", "w") do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
    plot.terminal "gif"
    plot.output "#{outputFile}.gif" 

    plot.xrange "[0:#{data.size}]"
    plot.title  "Prob of timeout given current build time"
    plot.ylabel "Probability"
    plot.xlabel "Minute"
    
    x = (1..data.size).collect { |v| v.to_f }
    y = data.collect {|z| z.to_f}

    plot.data = [
      Gnuplot::DataSet.new( [x, y] ) { |ds|
        ds.with = "linespoints"
        ds.title = "Array data"
      }
    ]

  end
end

end

plot(ARGV[1], ARGV[0])

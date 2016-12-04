#!/usr/bin/env ruby

require 'gnuplot'

if ARGV.size < 2
    puts "Usage: ./graph.rb outputFilepath prob1.txt (prob2.txt) ..."
    exit 1
end

def valid_data(filename)
    data = File.read(filename).split("\n")
    data = data.collect {|d| d.to_f }
    data.pop while data.last == 0
    data
end 

def plot(outputFilename, filenames)
    dataSets = filenames.collect {|fn| valid_data(fn)}
    maxX = 0
    dataSets.each {|data| maxX = data.size if data.size > maxX}
    outputFilename = outputFilename.split(".").first
File.open("#{outputFilename}.dat", "w") do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
    plot.terminal "png"
    plot.output "#{outputFilename}.png" 

    plot.xrange "[0:#{maxX}]"
    plot.title  "Prob of timeout given current build time"
    plot.ylabel "Probability"
    plot.xlabel "Minute"
    
    plots = dataSets.collect do |data|
        x = (1..data.size).collect { |v| v.to_f }
        y = data
    
        Gnuplot::DataSet.new( [x, y] ) { |ds|
          ds.with = "linespoints"
          ds.title = "Array data"
        }
    end
    plot.data = plots

  end
end

end

plot(ARGV[0], ARGV[1..-1])

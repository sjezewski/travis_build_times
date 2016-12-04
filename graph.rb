#!/usr/bin/env ruby

require 'gnuplot'

if ARGV.size < 2
    puts "Usage: ./graph.rb outputFilepath seq1name prob1.txt (seq1name prob2.txt) ..."
    exit 1
end

def valid_data(filename)
    data = File.read(filename).split("\n")
    data = data.collect {|d| d.to_f }
    data.pop while data.last == 0
    data
end 

def parse_labels(args)
    args.each_with_index.collect {|a, i| i % 2 == 0 ? a : nil }.compact
end

def parse_filenames(args)
    args.each_with_index.collect {|a, i| i % 2 == 1 ? a : nil }.compact
end

def plot(outputFilename, args)
    labels = parse_labels(args)
    filenames = parse_filenames(args)
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
    
    plots = dataSets.each_with_index.collect do |data, i|
        x = (1..data.size).collect { |v| v.to_f }
        y = data
    
        Gnuplot::DataSet.new( [x, y] ) { |ds|
          ds.with = "linespoints"
          ds.title = labels[i]
        }
    end
    plot.data = plots

  end
end

end

plot(ARGV[0], ARGV[1..-1])

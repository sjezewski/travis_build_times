#!/usr/bin/env ruby

require 'date'
require 'json'

# Split the data into a few groups

def string_to_date(raw)
    Date.parse raw
end

def is_in_range(raw_date, range)
    d = string_to_date(raw_date)
    return false if range[:start] > d
    return false if range[:end] < d
    true
end

def is_friday(raw_date)
    d = string_to_date(raw_date)
    d.strftime('%A') == "Friday"
end

def write_build(file, build)
   file << "#{build}\n"  
end

def filter(file)
    builds = JSON(File.read(file))

    rangeA = {:start => Date.new(2016, 3, 1), :end => Date.new(2016, 11, 17)}
    rangeB = {:start => Date.new(2016, 11, 19), :end => Date.new(2016, 12, 20)}

    # Set A: old travis VM builds
    setA = File.open("setA.json", "w")
    # Set A2: old travis VM builds on a friday
    setA2 = File.open("setA2.json", "w")
    # Set B: travis w upgraded VM builds
    setB = File.open("setB.json", "w")
    # Set B2: travis w upgraded VM builds on friday
    setB2 = File.open("setB2.json", "w")

    builds.each do |build|
        next if build['duration'] == 0
        build_time = build['started_at']
        if is_in_range(build_time, rangeA)
            write_build(setA, build)
            write_build(setA2, build) if is_friday(build_time)
        end
        if is_in_range(build_time, rangeB)
            write_build(setB, build)
            write_build(setB2, build) if is_friday(build_time)
        end
    end
end

filter(ARGV[0])

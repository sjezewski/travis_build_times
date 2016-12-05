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
   file << "#{build.to_json}\n"  
end

def load(buildsFile)
    raw = File.read(buildsFile)
    builds = []
    raw.split("\n").each do |line|
        builds << JSON(line)
    end
    builds
end

def filter(file, destFolder)
    builds = load(file)

    rangeA = {:start => Date.new(2016, 3, 1), :end => Date.new(2016, 11, 17)}
    rangeB = {:start => Date.new(2016, 11, 19), :end => Date.new(2016, 12, 20)}
    rangeC = {:start => Date.new(2016, 9, 24), :end => Date.new(2016, 11, 17)}

    # Set A: old travis VM builds
    setA = File.open(File.join(destFolder,"setA.json"), "w")
    # Set A2: old travis VM builds on a friday
    setA2 = File.open(File.join(destFolder,"setA2.json"), "w")
    # Set B: travis w upgraded VM builds
    setB = File.open(File.join(destFolder, "setB.json"), "w")
    # Set B2: travis w upgraded VM builds on friday
    setB2 = File.open(File.join(destFolder, "setB2.json"), "w")
    # Set C : old travis VM builds ... just since pfs refactor
    setC = File.open(File.join(destFolder,"setC.json"), "w")
    # Set C2: old travis VM builds on a friday (since pfs refactor)
    setC2 = File.open(File.join(destFolder,"setC2.json"), "w")

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
        if is_in_range(build_time, rangeC)
            write_build(setC, build)
            write_build(setC2, build) if is_friday(build_time)
        end
    end
end

filter(ARGV[0], ARGV[1])

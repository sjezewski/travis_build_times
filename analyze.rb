#!/usr/bin/env ruby

require 'json'

if ARGV.size != 2
    puts "Usage: ./analyze.rb some-builds.json outputDirectory"
    exit 1
end

# Given a set of data (via a single input file), computes the likelihood
# that a build will timeout given its age. We'll do this for each minute
# so that we can see how this likelihood changes. Ideally, we set our
# timeouts to match the 50% mark

# A : timeout
# B_x : build takes _at_least_ x minutes
#
# P(A|B_x) = P(B_x|A)P(A)/P(B_x)
#          = likelihood a build will timeout given its made it to at least X minutes
#
# P(B_x|A) = of the builds that timeout, how many made it to at least x minutes?
# P(A)     = global likelihood of timeout
# P(B_x)   = global likelihood of a build making it to x minutes

def classify(build)
    if build['duration'] == 0
        return :no_op
    end
    # 1 => failed
    # 0 => succeeded
    # null => errored
    if build['result'].nil?
        return :errored
    end
    # we don't care about success/failure since that's a function of the code being run
    return :finished
end

# Its important we traverse in order, so that we can calculate P(B_x|A)
def frequencies(builds)
    frequencies = {}
    builds.each do |build|
        klass = classify(build)
        frequencies[klass] = [] if frequencies[klass].nil?
        frequencies[klass] << build
    end

    frequencies
end

def prob_A(frequencies)
    # We discount no-ops 
    total = frequencies[:errored].size + frequencies[:finished].size
    frequencies[:errored].size.to_f/total
end

def prob_Bx(builds, x)
    cutoff = x*60 
    count = 0
    builds.each do |build|
        count += 1 if build['duration'] >= cutoff
    end
    count.to_f/builds.size
end

def prob_Bx_given_A(frequencies, x)
    prob_Bx(frequencies[:errored], x)
end

def prob_A_given_Bx(builds, frequencies, x)
    prob_Bx_given_A(frequencies,x) * prob_A(frequencies) / prob_Bx(builds, x)
end

def prob_of_timeout_for_all_times(builds)
    freq = frequencies(builds)
    minute = 0
    probs = []
    while minute < 55
           probs << prob_A_given_Bx(builds, freq, minute)
           minute += 1
    end
    probs
end 

def load(buildsFile)
    raw = File.read(buildsFile)
    builds = []
    raw.split("\n").each do |line|
        builds << JSON(line)
    end
    builds
end

probabilities = prob_of_timeout_for_all_times(load(ARGV[0]))
setName = File.split(ARGV[0]).last.split(".").first
File.open(File.join(ARGV[1], "#{setName}-prob.txt"), "w")  { |f| f << probabilities.join("\n") }

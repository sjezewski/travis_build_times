#!/usr/bin/env ruby

# Given a set of data (via a single input file), computes the likelihood
# that a build will timeout given its age at each minute

def classify(build)
    if build['duration'] == 0
        return :no_op
    end
    # 1 => failed
    # 0 => succeeded
    # null => errored
    if build['finished'] == nil
        return :errored
    end
    # we don't care about success/failure since that's a function of the code being run
    return :finished
end


def counts(builds)
    frequencies = {}
    builds.each do |build|
        klass = classify(build)
        frequencies[klass] = 0 if frequencies[klass].nil?
        frequencies[klass] += 1
    end

    frequencies
end

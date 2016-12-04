#!/usr/bin/env ruby

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
    if build['finished'] == nil
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




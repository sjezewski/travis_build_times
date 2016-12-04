#!/usr/bin/env ruby

require "http"
require "json"

$org_and_project = "pachyderm/pachyderm"

def repos_url(org_and_project)
  org_and_project.gsub("/", "%2F")
  "https://api.travis-ci.org/repos?slug=#{org_and_project}"
end

def builds_url(repo_id, filter="")
  "https://api.travis-ci.org/builds?#{filter}event_type%5B%5D=push&event_type%5B%5D=api&repository_id=#{repo_id}"
end

def next_builds_url(repo_id, furthest_build=nil)
  if furthest_build.nil?
    return builds_url(repo_id)
  end
  puts "last build:"
  puts furthest_build
  filter = "after_number=#{furthest_build['number']}&"
  builds_url(repo_id, filter)
end

def build_view_url(org_and_project, build_id)
  "https://travis-ci.org/#{org_and_project}/builds/#{build_id}"
end

resp = HTTP.get(repos_url($org_and_project))

repos = JSON.parse(resp.body)
done = false

last_build = nil
f = File.open("builds.json", "w")
count = 0



while !done
	puts "Page #{count+1}"
    resp = HTTP.get(next_builds_url(repos.first["id"], last_build))

    if resp.status.code != 200
        done = true
        break
    end
    builds = JSON.parse(resp)
    last_build = builds[-1]
	break if builds.size == 0
	builds.each {|b| f << "#{b.to_json}\n"}
	count += 1
end


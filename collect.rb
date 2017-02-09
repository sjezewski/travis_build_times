#!/usr/bin/env ruby

require "http"
require "json"

$org_and_project = "pachyderm/pachyderm"
# Look at an XHR request in the browser (e.g. when you click 'show more' / more builds) and look for the auth header
$token = File.read("session.token")

def repos_url()
  "https://api.travis-ci.org/repos/#{$org_and_project}"
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

def headers(token)
    {
        "Accept" => "application/vnd.travis-ci.2+json",
    }
end

def authenticate
    token = File.read("gh.token")
    body = {:github_token => token}
    options = {
        :headers => headers,
        :body => body.to_json
    }

    res = HTTP.post("https://api.travis-ci.org/auth/github", options)
    puts "auth response: #{res}\n"
end

def request(url)
    HTTP.get(url, {:headers => headers($token)})
end

puts "getting #{repos_url()}"
resp = request(repos_url())
repos = JSON.parse(resp.body)
repo_id = repos["repo"]["id"]
puts "got repo id: #{repo_id}"
done = false

last_build = nil
f = File.open("builds.json", "w")
count = 0

while !done
	puts "Page #{count+1}"
    next_url = next_builds_url(repo_id, last_build) 
    resp = HTTP.get(next_url)
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


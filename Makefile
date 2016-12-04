cluster:
	which pachctl
	echo 'y' | pachctl delete-all
	pachctl create-repo data
	docker build . -t travis_scripts 
	pachctl create-pipeline -f pipeline.json

input: cluster
	./collect.rb
	# Reverse the results so they're chronological
	# ... which will enable us to append / stream more data in if desired
	tac builds.json | pachctl put-file data -c -f 

collect:
	./collect.rb

local: collect
	./filter.rb builds.json ./tmp
	./analyze.rb ./tmp/setA.json ./tmp

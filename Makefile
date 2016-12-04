cluster:
	which pachctl
	echo 'y' | pachctl delete-all
	pachctl create-repo data
	pachctl create-pipeline -f pipeline.json


collect:
	./collect.rb .
	# Reverse the results so they're chronological
	# ... which will enable us to append / stream more data in if desired
	tac builds.json | pachctl 

analyze:


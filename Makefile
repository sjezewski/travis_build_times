cluster:
	which pachctl
	echo 'y' | pachctl delete-all
	pachctl create-repo data
	docker build . -t travis_scripts 
	pachctl create-pipeline -f pipeline.json

input:
	./collect.rb
	# Reverse the results so they're chronological
	# ... which will enable us to append / stream more data in if desired
	tac builds.json | pachctl put-file data -c -f 

collect:
	./collect.rb

analyze:
	./filter.rb builds.json ./tmp
	./analyze.rb ./tmp/setA.json ./tmp
	./analyze.rb ./tmp/setA2.json ./tmp
	./analyze.rb ./tmp/setB.json ./tmp
	./analyze.rb ./tmp/setB2.json ./tmp

graph:
	./graph.rb tmp/base.dat control tmp/setA-prob.txt upgradedVM tmp/setB-prob.txt
	gnuplot tmp/base.dat # generates tmp/base.png
	./graph.rb tmp/all.dat control tmp/setA-prob.txt upgradedVM tmp/setB-prob.txt controlFridays tmp/setA2-prob.txt upgradedVMFridays tmp/setB2-prob.txt
	gnuplot tmp/all.dat
	./graph.rb tmp/fridays.dat controlFridays tmp/setA2-prob.txt upgradedVMFridays tmp/setB2-prob.txt
	gnuplot tmp/fridays.dat 
	./graph.rb tmp/control.dat allDays tmp/setA-prob.txt fridays tmp/setA2-prob.txt
	gnuplot tmp/control.dat
	./graph.rb tmp/upgradedVM.dat allDays tmp/setB-prob.txt fridays tmp/setB2-prob.txt
	gnuplot tmp/upgradedVM.dat


local: collect analyze graph

pachyderm: cluster input

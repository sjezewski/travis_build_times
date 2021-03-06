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
	mkdir -p ./tmp
	./filter.rb builds.json ./tmp
	./analyze.rb ./tmp/setA.json ./tmp
	./analyze.rb ./tmp/setA2.json ./tmp
	./analyze.rb ./tmp/setA2prime.json ./tmp
	./analyze.rb ./tmp/setB.json ./tmp
	./analyze.rb ./tmp/setB2.json ./tmp
	./analyze.rb ./tmp/setB2prime.json ./tmp
	./analyze.rb ./tmp/setC.json ./tmp
	./analyze.rb ./tmp/setC2.json ./tmp
	./analyze.rb ./tmp/setC2prime.json ./tmp

graph:
	./graph.rb tmp/base.dat control tmp/setA-prob.txt upgradedVM tmp/setB-prob.txt
	gnuplot tmp/base.dat # generates tmp/base.png
	./graph.rb tmp/all.dat control tmp/setA-prob.txt upgradedVM tmp/setB-prob.txt controlFridays tmp/setA2-prob.txt upgradedVMFridays tmp/setB2-prob.txt sinceRefactor tmp/setC-prob.txt sinceRefactorFridays tmp/setC2-prob.txt
	gnuplot tmp/all.dat
	./graph.rb tmp/fridays.dat controlFridays tmp/setA2-prob.txt upgradedVMFridays tmp/setB2-prob.txt
	gnuplot tmp/fridays.dat 
	./graph.rb tmp/control.dat nonFridays tmp/setA2prime-prob.txt fridays tmp/setA2-prob.txt
	gnuplot tmp/control.dat
	./graph.rb tmp/upgradedVM.dat nonFridays tmp/setB2prime-prob.txt fridays tmp/setB2-prob.txt
	gnuplot tmp/upgradedVM.dat
	./graph.rb tmp/sinceRefactor.dat nonFridays tmp/setC2prime-prob.txt fridays tmp/setC2-prob.txt
	gnuplot tmp/sinceRefactor.dat
	./graph.rb tmp/refactorVsUpgrade.dat refactor tmp/setC-prob.txt upgradedVM tmp/setB-prob.txt
	gnuplot tmp/refactorVsUpgrade.dat



local: collect analyze graph

pachyderm: cluster input

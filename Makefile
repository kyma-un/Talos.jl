# Makefile - Talos.jl
# Author: Kyma

PROJ=Talos
TESTS_FOLDER=test

all:

run_tests:
	echo "Running talos test..."
	julia --project=. ${TESTS_FOLDER}/runtests.jl

view_docs:
	open docs/build/index.html

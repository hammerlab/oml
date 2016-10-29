

.PHONY: all clean test build setup doc 

default: FORCE
	@echo "available targets:"
	@echo "  build      	compiles Oml_lite and Oml if possible"
	@echo "  test       	runs unit tests"
	@echo "  doc        	generates ocamldoc documentations"
	@echo "  clean      	deletes all produced files"
	@echo "  setup-test 	opam install Oml and testing dependencies"
	@echo "  covered_test	runs unit tests with coverage"
	@echo "  report     	generate Bisect_ppx coverage report"


# This should be called something else.
setup:
	opam install $(PACKAGES_INSTALL)

setup-test:
	opam pin add dsfo git://github.com/rleonid/dsfo
	opam install $(PACKAGES_INSTALL_TEST)

#### Building

build:
	topkg build

clean:
	topkg clean

#### Testing

test: 
	topkg build -n omltest && time topkg test

covered_test: covered_test.native
	time ./oml_test.native ${TEST}


#### Test Coverage

report_dir:
	mkdir report_dir

# By running bisect-ppx-report in the actual directory with the modified source path
# (ie. the *.ml has the *.mlt inside of it with our label), we get proper
# alignment of the html!
report: report_dir
	cd $(TEST_BUILD_DIR) && \
	bisect-ppx-report -html ../report_dir ../$(shell ls -t bisect*.out | head -1) && \
	cd -

clean_reports:
	rm -rf report_dir bisect*.out

#### Documentation

oml.odocl:
	cp src/lib/oml.mlpack oml.odocl

# including the cmi as build targets triggers all of the including logic
# to get saner documentation.
doc:
	$(OCAMLBUILD) -build-dir $(DOC_BUILD_DIR) \
		$(foreach package, $(PACKAGES),-package $(package)) \
		$(foreach sd, $(SOURCE_DIRS), -I src/lib$(sd)) -I src/lib oml.cmi doc.docdir/index.html

FORCE:

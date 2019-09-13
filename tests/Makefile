
conftest:
	kustomize build . | conftest test -p ../policies -

tests:
	opa test -v ../policies

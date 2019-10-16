
conftest:
	kustomize build . | conftest test -p ../policy/kubernetes -

tests-kube:
	opa test -v ../policy/kubernetes

tests-docker:
	opa test -v ../policy/docker

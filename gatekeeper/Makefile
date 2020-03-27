create-cluster:
	bash kind.sh

delete-cluster:
	kind delete cluster

apply:
	kustomize build | kubectl apply -f - --kubeconfig=config.yml

build:
	kustomize build

gatekeeper-templates:
	kubectl get constrainttemplates.templates.gatekeeper.sh

gatekeeper-constraints:
	kubectl get crd | grep constraints | awk '{print $$1}'

apply-test-allow:
	kubectl apply -f test/deployment-allowed.yml

apply-test-reject:
	kubectl apply -f test/deployment-not-allowed.yml

delete-test-allow:
	kubectl delete -f test/deployment-allowed.yml

delete-test-reject:
	kubectl delete -f test/deployment-not-allowed.yml

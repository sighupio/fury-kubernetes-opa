apply:
	kustomize build | kubectl apply -f - --kubeconfig=config.yml

build:
	kustomize build


test-allow:
	kubectl apply -f test/deployment-allowed.yml

test-reject:
	kubectl apply -f test/deployment-not-allowed.yml

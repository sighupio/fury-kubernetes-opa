#!/usr/bin/env bats

set -o pipefail

kaction(){
    path=$1
    verb=$2
    kustomize build $path | kubectl $verb -f -
}


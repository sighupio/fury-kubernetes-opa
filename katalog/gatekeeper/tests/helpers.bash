#!/usr/bin/env bats


kaction(){
    path=$1
    verb=$2
    kustomize build $path | kubectl $verb -f -
}


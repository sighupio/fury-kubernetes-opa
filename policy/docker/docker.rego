package main

deny[msg] {
	msg = json.marshal(input)
}

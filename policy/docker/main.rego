package main

blacklist = [
  "jboss"
]

invalidcmds = ["ssh", "vim", "shutdown", "service", "ps", "free", "top", "kill", "mount"]

deny[msg] {
  input[i].Cmd == "from"
  val := input[i].Value
  contains(val[0], blacklist[_])

  msg = sprintf("blacklisted repository found '%s'", val)
}

# DL3000
deny[msg] {
    input[i].Cmd == "workdir"
    val := input[i].Value
    not startswith(val[0], "/")
    not startswith(val[0], "$")
    msg := sprintf("[DL3000] WORKDIR '%v' must be an absolute path", val)
}

#DL3001
deny[msg] {
    input[i].Cmd == "run"
    val := input[i].Value
    cmds := regex.split("[ &;]+", val[0])
    re_match(cmds[j], invalidcmds[_])
    msg := sprintf("[DL3001] line %v: command '%v' does not make sense in a container", [i+1, cmds[j]])
}

get_users(in) = users {
    users := [y | y := in[x].Value[0]; in[x].Cmd == "user"]
}

#DL3002
deny[msg] {
    users := get_users(input)
    users[count(users)-1] == "root"
    msg := "[DL3002] Las user should not be root"
}

#DL3002
deny[msg] {
    users := get_users(input)
    users[count(users)-1] == "0"
    msg := "[DL3002] Las user should not be root"
}

#DL3002
deny[msg] {
    users := get_users(input)
    count(users) == 0
    msg := "[DL3002] User should be set"
}

#DL3005
deny[msg] {
    input[i].Cmd == "run"
    val := input[i].Value
    cmds := regex.split("[ &;]+", val[0])
    cmds[x] == "apt-get"
    cmds[x+1] == "upgrade"
    msg := "[DL3005] Do not use apt-get upgrade"
}

# DL3011
deny[msg] {
    input[i].Cmd == "expose"
    val := input[i].Value
    to_number(val[j]) > 65535
    msg := sprintf("[DL3011] line %v: Invalid port %v. Valid UNIX ports range from 0 to 65535", [i, val[j]])
}

# DL3021
deny[msg]{
    input[i].Cmd == "copy"
    val := input[i].Value
    count(val) > 2
    not endswith(val[count(val)-1], "/")
    msg := "[DL3021] COPY with more than 2 arguments requires the last argument to end with /"
}

#DL3027
deny[msg] {
    input[i].Cmd == "run"
    val := input[i].Value
    cmds := regex.split("[ &;]+", val[0])
    cmds[_] == "apt"
    msg := sprintf("[DL3027] line %v: Do not use apt as it is meant to be a end-user tool, use apt-get or apt-cache instead", [i+1])
}

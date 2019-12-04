package main

blacklist = [
  "jboss"
]

warn[msg] {
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
    msg := sprintf("WORKDIR '%v' must be an absolute path", val)
}

# DL3011
deny[msg] {
    input[i].Cmd == "expose"
    val := input[i].Value
    to_number(val[0]) > 65535
    msg := sprintf("Invalid port %v. Valid UNIX ports range from 0 to 65535", val)
}

# DL3021
deny[msg]{
    input[i].Cmd == "copy"
    val := input[i].Value
    count(val) > 2
    not endswith(val[count(val)-1], "/")
    msg := "COPY with more than 2 arguments requires the last argument to end with /"
}

#DL3027
deny[msg] {
    input[i].Cmd == "run"
    val := input[i].Value
    cmds := split(val[0], " ")
    cmds[_] == "apt"
    msg := "Do not use apt as it is meant to be a end-user tool, use apt-get or apt-cache instead"
}

## For OSX:
PATH=$PATH:/usr/libexec

slapd -d 1 -f slapd-test.conf -h ldap://localhost:3389

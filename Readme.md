# Debug for Apache + php Segmentation Fault

> Example of how to investigate causes such as apache process timeout, php error, segmentation fault, etc in apache + php service in operation.
> In this sample, we are trying adding php extensions to deliberately generate a segmentation fault.

### Setup

```sh
# build and run container
docker build -t kazu69/debug_apache_php_with_gdb .
docker run -d \
           -p 8080:80 \
           --privileged \
           --ulimit core=9999999999 \
           --cap-add=SYS_PTRACE \
           --security-opt seccomp:unconfined \
           kazu69/debug_apache_php_with_gdb
```

## Debug

### strace

```sh
docker exec -it $(docker ps -q) /bin/bash

# check process
pstree -p
apache2(1)---apache2(15)

# trace kernel system call using strace
strace -p 15
Process 15 attached
accept4(3...

# access http://localhost:8080/
```

### gdb with core file

php Segmentation Fault

```sh
docker exec -it $(docker ps -q) /bin/bash

# php segmentation fault debug using core file
php error.php
Segmentation fault (core dumped)

ls /tmp/
core.6e57d3062300.php.xxxxxxxxxx

gdb /usr/local/bin/php /tmp/core.6e57d3062300.php.xxxxxxxxxx
```

apache process with php segmentation fault debug using core file

```sh
# core pattern apache error core file
echo '/tmp/core.%h.%e.%t' > /proc/sys/kernel/core_pattern

# access to http://localhost:8080/error.php

ls tmp/
core.6e57d3062300.apache2.xxxxxxxxxx

# debug with gdb
gdb /usr/sbin/apache2 -c core.6e57d3062300.apache2.xxxxxxxxxx
```

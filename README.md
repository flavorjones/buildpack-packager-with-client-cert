# using `buildpack-packager` with a client certificate

This project demonstrates how to use buildpack-packager in an
environment where buildpack artifacts are hosted on secure servers
that require authenticaiton via client certificate.

We'll use the `cloudfoundry/cflinuxfs` docker image to host an nginx
server that requires a valid client certificate. Then we'll test that
configuration. And finally, we'll create a dummy buildpack using
`buildpack-packager` that downloads an artifact from our nginx server.


## what's going on here

We're demonstrating that you can create a `.curlrc` file specifying
the client certificate (and key, if necessary), and set the
`CURL_HOME` environment variable to make sure that `curl` will load
that `.curlrc`


## prerequisites

This proof-of-concept will require that you have the following
installed on your local (Linux) system:

* public internet connectivity
* [docker](https://docs.docker.com/linux/step_one/)
* ruby and rubygems


### Docker image

First, make sure you have that docker image:

```
docker pull cloudfoundry/cflinuxfs2
```

You should see something like:

```
Using default tag: latest
latest: Pulling from cloudfoundry/cflinuxfs2
5e1136df5175: Pull complete 
Digest: sha256:c12b9221a66eee9987d29d6feef7bb80aeb82f2bef346255dad966e74e025e45
Status: Downloaded newer image for cloudfoundry/cflinuxfs2:latest
```


### Ruby environment

Then, make sure you've resolved the ruby dependencies:

```
bundle install
```


## setting up the nginx server

In a separate terminal session, run:

```
bundle exec rake nginx:start
```

You should see:

```
Selecting previously unselected package nginx-common.
(Reading database ... 27964 files and directories currently installed.)
Preparing to unpack .../nginx-common_1.4.6-1ubuntu3.4_all.deb ...
Unpacking nginx-common (1.4.6-1ubuntu3.4) ...
Selecting previously unselected package nginx-core.
Preparing to unpack .../nginx-core_1.4.6-1ubuntu3.4_amd64.deb ...
Unpacking nginx-core (1.4.6-1ubuntu3.4) ...
Selecting previously unselected package nginx.
Preparing to unpack .../nginx_1.4.6-1ubuntu3.4_all.deb ...
Unpacking nginx (1.4.6-1ubuntu3.4) ...
Processing triggers for ureadahead (0.100.0-16) ...
Setting up nginx-common (1.4.6-1ubuntu3.4) ...
Processing triggers for ureadahead (0.100.0-16) ...
Setting up nginx-core (1.4.6-1ubuntu3.4) ...
invoke-rc.d: policy-rc.d denied execution of start.
Setting up nginx (1.4.6-1ubuntu3.4) ...

  When prompted, enter 'asdf' for the PEM passphrase.

Enter PEM pass phrase:

  When you're done, simply 'exit'.

root@9d7d88eefeaf:/# 
```

**Leave this session open until you're done.**


## validating the setup and showing we can build a buildpack

In a new terminal session, run:

```
bundle exec rake
```

You should see something like:

```
#
#  This request should fail to authenticate:
#
<html>
<head><title>400 No required SSL certificate was sent</title></head>
<body bgcolor="white">
<center><h1>400 Bad Request</h1></center>
<center>No required SSL certificate was sent</center>
<hr><center>nginx/1.4.6 (Ubuntu)</center>
</body>
</html>
#
#  This request should successfully authenticate:
#
<html>
  <head>
    <title>
      Authenticated page
    </title>
  </head>
  <body>
    <h1>Authenticated page</h1>
    <p>
      You should only be able to see this page if you've made an
      authenticated connection.
    </p>
  </body>
</html>
#
#  SUCCESS.
#
deleting cached file /home/flavorjones/.buildpack-packager/cache/https___localhost_4443_index.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   249  100   249    0     0  33983      0 --:--:-- --:--:-- --:--:-- 35571
#
#  SUCCESS.
#
```

Now there's a buildpack named `foo_buildpack-cached-v1.0.zip` that
contains the "index.html" artifact from the nginx server.

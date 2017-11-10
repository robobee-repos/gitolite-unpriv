# Gitolite

## Description

Modifies the Dockerfile from [elsdoerfer/gitolite](https://hub.docker.com/r/elsdoerfer/gitolite/) to run Gitolite and Sshd as an unprivileged user on port 2222.

## Environment

| Variable | Description |
| ---- | ----- |
| `SSH_KEY`  | Ssh public key to access the gitolite-admin repository. |

## Exposed Ports

| Port | Description |
| ---- | ----- |
| 2222  | ssh |

## Directories

| Path | Description |
| --------- | ----- |
| /home/git/repositories  | Gitolite repositories. |

## Input Configuration

| Source | Destination | Description |
| -------- | --------- | ------------- |
| /ssh-in  | /etc/sshd | Directory for created sshd keys and the sshd configuration. |

## Test

The docker-compose file `test.yaml` can be used to startup the container. The installation can be then accessed from `localhost:2222`.

```
cd test
make test
```

## License

gitolite is published under the [GPL v2](http://gitolite.com/gitolite/index.html#license)

This image is licensed under the [MIT](https://opensource.org/licenses/MIT) license.

Copyright 2017 Erwin Müller

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

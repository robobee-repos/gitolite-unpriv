include ../utils/Makefile.help
include ../utils/Makefile.functions

NAME := gitolite-unpriv
SSH_VOLUME := root/ssh-in
REPOS_VOLUME := root/repos
ADMIN_KEY := root/gitolite_key

test: setup ##@targets Starts test containers.
	export SSH_VOLUME=$$(realpath $(SSH_VOLUME)) && \
	export REPOS_VOLUME=$$(realpath $(REPOS_VOLUME)) && \
	export SSH_KEY="$$(cat $(ADMIN_KEY).pub)" && \
	docker-compose -p ${NAME} -f test.yaml up
.PHONY: up

stop: ##@targets Stops test containers.
	docker-compose -p ${NAME} -f test.yaml stop

clean: stop ##@targets Removes docker containers and created files.
	docker-compose -p ${NAME} -f test.yaml rm
	if [ -d "root" ]; then \
	sudo rm -rf "root" ; \
	fi
	if [ -d gitolite-admin ]; then \
	rm -rf gitolite-admin ; \
	fi
	if [ -e log.txt ]; then \
	rm -r log.txt ; \
	fi

setup:
	mkdir -p root
	if [ ! -e "$(ADMIN_KEY)" ]; then \
	ssh-keygen -f $(ADMIN_KEY) -N '' -t rsa ; \
	fi
	export SSH_VOLUME="$(SSH_VOLUME)" \
	&& if [ ! -d "$$SSH_VOLUME" ]; then \
	sudo mkdir -p "$$SSH_VOLUME" && \
	sudo chown 105.108 -R "$$SSH_VOLUME" ; \
	fi
	export REPOS_VOLUME="$(REPOS_VOLUME)" \
	&& if [ ! -d "$$REPOS_VOLUME" ]; then \
	sudo mkdir -p "$$REPOS_VOLUME" && \
	sudo chown 105.108 -R "$$REPOS_VOLUME" ; \
	fi

ls-remote:
	ssh-agent bash -c "ssh-add `realpath $(ADMIN_KEY)`; git ls-remote ssh://git@localhost:2222/gitolite-admin"

clone:
	ssh-agent bash -c "ssh-add `realpath $(ADMIN_KEY)`; git clone ssh://git@localhost:2222/gitolite-admin"

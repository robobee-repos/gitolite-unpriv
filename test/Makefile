include ../utils/Makefile.help
include ../utils/Makefile.functions

export NAME=gitolite
export GIT_VOLUME=./root/git
export ADMIN_KEY=./root/gitolite_key

test: setup ##@targets Starts test containers.
	export SSH_KEY="`cat $$ADMIN_KEY.pub`"; \
	docker-compose -p $(NAME) -f test.yaml up
.PHONY: up

stop: ##@targets Stops test containers.
	export SSH_KEY="`cat $$ADMIN_KEY.pub`"; \
	docker-compose -p $(NAME) -f test.yaml stop

rm: ##@targets Removes test containers.
	export SSH_KEY="`cat $$ADMIN_KEY.pub`"; \
	docker-compose -p $(NAME) -f test.yaml rm -f

clean: stop rm ##@targets Removes docker containers and created files.
	sudo rm -rf "root"
	rm -rf gitolite-admin
	rm -rf log.txt

setup: root $(ADMIN_KEY) $(GIT_VOLUME)

ls-remote:
	ssh-agent bash -c "ssh-add `realpath $(ADMIN_KEY)`; git ls-remote ssh://git@localhost:2222/gitolite-admin"

clone:
	ssh-agent bash -c "ssh-add `realpath $(ADMIN_KEY)`; git clone ssh://git@localhost:2222/gitolite-admin"

root:
	mkdir -p root

$(ADMIN_KEY):
	ssh-keygen -f $@ -N '' -t rsa

$(GIT_VOLUME):
	sudo mkdir -p $@
	sudo chown root.108 -R $@
	sudo chmod u=rwX,g=rwX,o= -R $@


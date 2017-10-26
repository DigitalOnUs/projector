all:
	@echo "This is the default target. I do nothing. :P"

deploy:
	./scripts/deploy/deploy.sh

redeploy:
	./scripts/deploy/deploy.sh -s

destroy:
	./scripts/deploy/destroy.sh

exec:
	./scripts/control/start.sh

.PHONY: all deploy redeploy destroy exec

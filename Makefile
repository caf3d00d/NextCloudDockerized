all: proxy nextcloud

proxy:
	docker-compose -f proxy/docker-compose.yml up -d

nextcloud:
	docker-compose -f nextcloud/docker-compose.yml up -d

stop:
	docker-compose -f proxy/docker-compose.yml down
	docker-compose -f nextcloud/docker-compose.yml down

prune: stop
	@sudo rm -rf proxy/data proxy/letsencrypt
	@sudo rm -rf nextcloud/data nextcloud/sql

restart: stop all

reset: prune all

.PHONY: proxy nextcloud prune

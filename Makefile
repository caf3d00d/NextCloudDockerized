all: proxy nextcloud

proxy:
	docker-compose -f proxy/docker-compose.yml up -d

nextcloud:
	docker-compose -f nextcloud/docker-compose.yml up -d

prune:
	@ docker system prune -f

.PHONY: proxy nextcloud prune

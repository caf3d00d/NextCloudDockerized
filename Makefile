all: proxy nextcloud

proxy:
	docker-compose -f proxy/docker-compose.yml up --build

nextcloud:
	docker-compose -f proxy/docker-compose.yml up --build

prune:
	@ docker system prune -f

.PHONY: proxy nextcloud prune

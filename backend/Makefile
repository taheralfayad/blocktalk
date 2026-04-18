# Makefile 

CONTAINER_NAME=blocktalk_backend

create-user:
	docker compose exec $(CONTAINER_NAME) go run scripts/create_user.go

create-user-prod:
	docker compose exec $(CONTAINER_NAME) ./scripts/create_user

start:
	docker compose up --build --detach

stop:
	docker compose stop

exec:
	docker compose exec mysql bash

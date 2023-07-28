start:
	docker compose up --build --detach

stop:
	docker compose stop

exec:
	docker compose exec mysql bash

#mysql:
#	docker compose run mysql mysql -utest -psecret
##
# Project Title
#
# @file
# @version 0.1

bash:
	@docker compose run -p 3000:3000 --name app test bash
	@docker compose down

start:
	@docker compose up --build web sidekiq

##
# Project Title
#
# @file
# @version 0.1

bash:
	@docker compose run -p 3000:3000 --name app test bash

start:
	@docker compose up web sidekiq

-include .docker.local

# Собираем все yml файлы в корне в одну команду
COMPOSE_FILES := $(foreach file,$(wildcard *.yml),-f $(file))
COMPOSE := docker compose -p $(PROJECT_ALIAS) --env-file .docker.local $(COMPOSE_FILES)

.PHONY: build start stop restart shell logs help init artisan

help: ## Справка
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

init: ## Создать конфиг .docker.local из примера
	@cp .docker.local.example .docker.local && echo "Created .docker.local"

build: ## Сборка образов
	$(COMPOSE) build

start: ## Запуск всех контейнеров
	@$(COMPOSE) up -d
	@echo "-------------------------------------------------------"
	@echo "Project:    $(PROJECT_ALIAS)"
	@echo "Webserver:  http://$(NETWORK_SUBNET).4"
	@echo "Database:   $(NETWORK_SUBNET).3"
	@echo "-------------------------------------------------------"

stop: ## Остановка и удаление контейнеров
	$(COMPOSE) down --remove-orphans

restart: stop start ## Перезапуск

shell: ## Вход в контейнер приложения
	$(COMPOSE) exec -u www-data app bash

logs: ## Просмотр логов приложения
	$(COMPOSE) logs -f app

artisan: ## Выполнить artisan команду (пример: make artisan migrate)
	$(COMPOSE) exec -u www-data app php artisan $(filter-out $@,$(MAKECMDGOALS))

# Пустая цель, чтобы make не ругался на аргументы artisan как на неизвестные цели
%:
	@:

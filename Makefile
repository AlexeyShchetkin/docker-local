-include .docker.local

# Список compose-файлов задаётся в .docker.local как COMPOSE_FILES (пути через пробел).
COMPOSE_FILE_ARGS := $(foreach file,$(COMPOSE_FILES),-f $(file))
COMPOSE := docker compose -p $(PROJECT_ALIAS) --project-directory $(CURDIR) --env-file .docker.local $(COMPOSE_FILE_ARGS)

.PHONY: build start stop down restart shell logs help init check-config ps config pull

check-config: ## Проверить .docker.local, PROJECT_ALIAS, NETWORK_SUBNET и COMPOSE_FILES
	@test -f .docker.local || (printf '%s\n' "Ошибка: нет файла .docker.local. Выполните: make init" >&2 && exit 1)
	@test -n "$(PROJECT_ALIAS)" || (printf '%s\n' "Ошибка: в .docker.local не задан или пустой PROJECT_ALIAS" >&2 && exit 1)
	@test -n "$(NETWORK_SUBNET)" || (printf '%s\n' "Ошибка: в .docker.local не задан или пустой NETWORK_SUBNET" >&2 && exit 1)
	@test -n "$(COMPOSE_FILES)" || (printf '%s\n' "Ошибка: в .docker.local не задан или пустой COMPOSE_FILES (список compose-файлов через пробел, см. .docker.local.example)" >&2 && exit 1)

help: ## Справка
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

init: ## Создать конфиг .docker.local из примера
	@cp .docker.local.example .docker.local && echo "Created .docker.local"

build: check-config ## Сборка образов
	$(COMPOSE) build

start: check-config ## Запуск всех контейнеров
	@$(COMPOSE) up -d
	@echo "-------------------------------------------------------"
	@echo "Project:    $(PROJECT_ALIAS)"
	@echo "Web:        http://$(NETWORK_SUBNET).4"
	@echo "БД / IP:    $(NETWORK_SUBNET).3"
	@echo "-------------------------------------------------------"

stop: check-config ## Остановка и удаление контейнеров
	$(COMPOSE) down --remove-orphans

down: check-config ## То же, что stop (docker compose down --remove-orphans)
	$(COMPOSE) down --remove-orphans

ps: check-config ## Список контейнеров
	$(COMPOSE) ps

config: check-config ## Итоговая конфигурация compose (проверка YAML)
	$(COMPOSE) config

pull: check-config ## Обновить образы из registry (без локальной сборки)
	$(COMPOSE) pull

restart: stop start ## Перезапуск

shell: check-config ## Вход в контейнер приложения
	$(COMPOSE) exec -u www-data app bash

logs: check-config ## Просмотр логов приложения
	$(COMPOSE) logs -f app

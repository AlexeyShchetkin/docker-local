# Docker environment for local development

Модульная Docker-инфраструктура для локальной разработки PHP-приложений (**Laravel** и **Symfony**). Compose-файлы лежат в **`modules/`**, в корень копировать их не нужно: список задаётся в **`.docker.local`** переменной **`COMPOSE_FILES`**.

## Особенности

- **Сборка**: `make` вызывает `docker compose` с **`--project-directory`** = корень репозитория, поэтому пути вроде `./src/` и `context: modules/laravel` в YAML остаются как при копировании в корень.
- **Стеки**: **`modules/laravel/laravel.yml`** и **`modules/symfony/symfony.yml`** — подключайте нужный в **`COMPOSE_FILES`**.
- **Web**: **Nginx** — **`modules/nginx/nginx.yml`**; при необходимости замените своим веб-сервером (отдельный YAML в `modules/` и путь в **`COMPOSE_FILES`**).
- **Сервисы**: **`modules/pgsql.yml`**, **`modules/redis.yml`**, **`modules/mysql.yml`** и т.д. — добавляйте пути в **`COMPOSE_FILES`** по необходимости.
- **Только Laravel**: **`modules/laravel/horizon.yml`** и **`scheduler.yml`** — отдельные сервисы; при изменении **`x-common-app`** в `laravel.yml` синхронизируйте эти файлы.

## Требования

- Docker >= 20.10
- Docker Compose v2
- Make

Команды **`make`** выполняйте из **корня репозитория** (для `--project-directory` и путей в **`COMPOSE_FILES`**).

## Быстрый старт

1. **Инициализация конфига**:
   ```bash
   make init
   ```
   Создаётся `.docker.local` из шаблона (в нём уже есть пример **`COMPOSE_FILES`**).

2. **Настройка**  
   Отредактируйте `.docker.local`:
   - **`PROJECT_ALIAS`**, **`NETWORK_SUBNET`**
   - **`COMPOSE_FILES`** — пробелом разделённые пути к compose-файлам **относительно корня репозитория**, например:
     - Laravel: `modules/laravel/laravel.yml`
     - Symfony: `modules/symfony/symfony.yml`
     - фронт: `modules/nginx/nginx.yml`
     - БД: `modules/pgsql.yml` или `modules/mysql.yml`
     - кэш: `modules/redis.yml`
     - очереди Laravel: `modules/laravel/horizon.yml` (вместе с `laravel.yml`)

3. **Переменные БД** — `DB_NAME`, `DB_USERNAME`, `DEFAULT_PASSWORD`. С хоста БД доступна по **`${NETWORK_SUBNET}.3`** (порт `5432` для Postgres или `3306` для MySQL — смотря что в **`COMPOSE_FILES`**).

4. **Сборка и запуск**:
   ```bash
   make build
   make start
   ```

5. **Код** — в **`src/`**.

## Консоль приложения (Laravel / Symfony)

```bash
make shell
php artisan …
# или
php bin/console …
```

## Команды Make

| Команда | Описание |
| :--- | :--- |
| `make init` | Создать `.docker.local` |
| `make check-config` | Проверить `.docker.local`, `PROJECT_ALIAS`, `NETWORK_SUBNET`, `COMPOSE_FILES` |
| `make build` | Сборка образов |
| `make start` | Запуск |
| `make stop` | Остановка |
| `make down` | То же, что `stop` |
| `make ps` | Список контейнеров |
| `make config` | Итоговый compose (проверка YAML) |
| `make pull` | Обновить образы из registry |
| `make restart` | Перезапуск |
| `make shell` | Bash в `app` |
| `make logs` | Логи `app` |
| `make help` | Справка |

## Структура `modules/`

```
modules/
  laravel/
    Dockerfile
    config/
    laravel.yml
    horizon.yml
    scheduler.yml
  symfony/
    Dockerfile
    config/
    symfony.yml
  nginx/
    Dockerfile
    nginx.yml
    config/
  pgsql.yml
  redis.yml
  mysql.yml
```

**Почему Horizon/Scheduler в `modules/laravel/`:** процессы `php artisan …`, не общая инфраструктура.

Файл **`/app.yml`** в `.gitignore` оставлен на случай старого сценария с копированием в корень; при работе через **`COMPOSE_FILES`** он не нужен.

## Сеть и доступ

При `NETWORK_SUBNET=10.10.100` (по умолчанию в фрагментах):

- **Web** (nginx): `10.10.100.4`
- **Приложение** (PHP-FPM): `10.10.100.2`
- **PostgreSQL** (`pgsql.yml`) и **MySQL** (`mysql.yml`): оба на **`10.10.100.3`** (порты разные: `5432` и `3306`). В **`COMPOSE_FILES`** держите **только одну** СУБД — иначе конфликт IP на сети.
- **Redis** (`redis.yml`): `10.10.100.5`

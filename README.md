# Micro SQL — учебный стенд аналитики интернет-магазина

Набор SQL-скриптов для MySQL 8, который поднимается в Docker и сразу содержит схему, тестовые данные, хранимые процедуры/функции и готовые аналитические запросы. Проект удобен для демонстрации витрины заказов и экспериментов с аналитикой.

## Что внутри
- `docker-compose.yml` — MySQL 8 + Adminer, все настройки берутся из `.env`.
- `db/init/001_schema.sql` — таблицы пользователей, товаров, заказов, позиций, отзывов, категории и индексы.
- `db/init/002_seed.sql` — генерация тестового набора данных 2024–2025 гг.
- `db/init/003_routines.sql` — функция `calculate_user_rank` и процедура `generate_monthly_report`.
- `db/analytics/004_analytics.sql` — 10 готовых запросов: топы товаров/покупателей, средний чек, воронка, когорты по месяцам и др.
- `scripts/backup.sh` и `scripts/restore.sh` — бэкап/восстановление БД из контейнера.
- `docs/sql_queries_explained.md` — построчные разборы всех запросов.

## Требования
- Docker и Docker Compose.
- Свободные порты `3306` (MySQL) и `8080` (Adminer).

## Быстрый старт
1) Скопируйте или отредактируйте `.env` при необходимости (по умолчанию: база `shop_analytics`, пользователь/пароль `app/app_pass`, root `root_pass`).
2) Запустите сервисы:  
   ```bash
   docker compose up -d
   ```
3) Дождитесь готовности MySQL (healthcheck уже настроен).
4) Подключитесь к базе:  
   ```bash
   docker exec -it shop_mysql mysql -uapp -papp_pass shop_analytics
   ```
   Adminer доступен по адресу http://localhost:8080 (сервер `mysql`, БД `shop_analytics`, пользователь `app`, пароль `app_pass`).

## Запуск аналитических запросов
Выполнить сразу весь набор запросов:  
```bash
docker exec -i shop_mysql mysql -uapp -papp_pass shop_analytics < db/analytics/004_analytics.sql
```

## Генерация ежемесячного отчета
Процедура пересчитает агрегаты и сохранит их в `monthly_reports` (с upsert):
```sql
CALL generate_monthly_report('2025-11-01');
SELECT * FROM monthly_reports;
```

## Бэкап и восстановление
- Создать дамп (по умолчанию складывается в `backups/`, старше 14 дней чистятся):  
  ```bash
  ./scripts/backup.sh
  ```
- Восстановить из файла:  
  ```bash
  ./scripts/restore.sh backups/имя_дампа.sql
  ```

## Полезные ссылки
- Разбор запросов: `docs/sql_queries_explained.md`.
- Стартовые скрипты базы: файлы в `db/init`.
- Примеры аналитики: `db/analytics/004_analytics.sql`.

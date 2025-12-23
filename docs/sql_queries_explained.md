# Подробное объяснение всех SQL-запросов проекта

Документ описывает каждую строку SQL-скриптов в `db/init` и `db/analytics`. Формат: показываем фрагмент кода и поясняем строки в порядке следования.

## db/init/001_schema.sql

### Создание базы и выбор схемы
```sql
CREATE DATABASE IF NOT EXISTS shop_analytics
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```
- `CREATE DATABASE IF NOT EXISTS shop_analytics` — создаёт БД `shop_analytics`, если она ещё не существует, чтобы не упасть при повторном запуске.
- `  CHARACTER SET utf8mb4` — задаёт полный UTF-8 набор символов для хранения текста.
- `  COLLATE utf8mb4_unicode_ci;` — устанавливает сортировку/сравнение строк с учётом Unicode и без учета регистра.

```sql
USE shop_analytics;
```
- `USE shop_analytics;` — переключает контекст выполнения последующих запросов на созданную БД.

### Таблица users
```sql
-- =========================
-- users
-- =========================
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  registration_date DATE NOT NULL,
  city VARCHAR(50),
  total_orders INT DEFAULT 0,
  total_spent DECIMAL(10,2) DEFAULT 0
) ENGINE=InnoDB;
```
- `-- =========================` — визуальный разделитель блока.
- `-- users` — заголовок блока для таблицы пользователей.
- `-- =========================` — закрывающий разделитель.
- `CREATE TABLE users (` — начало определения таблицы `users`.
- `  user_id INT AUTO_INCREMENT PRIMARY KEY,` — числовой идентификатор, автоинкремент и первичный ключ.
- `  username VARCHAR(50) NOT NULL UNIQUE,` — логин до 50 символов, обязателен и уникален.
- `  email VARCHAR(100) NOT NULL UNIQUE,` — email до 100 символов, обязателен и уникален.
- `  registration_date DATE NOT NULL,` — дата регистрации, обязательное поле.
- `  city VARCHAR(50),` — город, необязательное поле.
- `  total_orders INT DEFAULT 0,` — число заказов, по умолчанию 0.
- `  total_spent DECIMAL(10,2) DEFAULT 0` — сумма потраченных средств, по умолчанию 0.
- `) ENGINE=InnoDB;` — завершение таблицы с использованием движка InnoDB.

### Таблица categories
```sql
-- =========================
-- categories
-- =========================
CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL,
  parent_category_id INT NULL,
  CONSTRAINT fk_categories_parent
    FOREIGN KEY (parent_category_id)
    REFERENCES categories(category_id)
    ON DELETE SET NULL
) ENGINE=InnoDB;
```
- `-- ...` — разделители блока категорий.
- `CREATE TABLE categories (` — начало таблицы категорий.
- `  category_id INT AUTO_INCREMENT PRIMARY KEY,` — ключ категории с автоинкрементом.
- `  category_name VARCHAR(100) NOT NULL,` — обязательное имя категории.
- `  parent_category_id INT NULL,` — ссылка на родительскую категорию, может быть NULL.
- `  CONSTRAINT fk_categories_parent` — объявление имени внешнего ключа.
- `    FOREIGN KEY (parent_category_id)` — внешний ключ строится по полю `parent_category_id`.
- `    REFERENCES categories(category_id)` — ссылка на первичный ключ в этой же таблице (рекурсивная иерархия).
- `    ON DELETE SET NULL` — при удалении родителя ссылка обнуляется.
- `) ENGINE=InnoDB;` — завершение определения таблицы.

### Таблица products
```sql
-- =========================
-- products
-- =========================
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  product_name VARCHAR(200) NOT NULL,
  category_id INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  stock_quantity INT DEFAULT 0,
  average_rating DECIMAL(3,2) DEFAULT 0,
  created_at DATE NOT NULL,
  CONSTRAINT fk_products_category
    FOREIGN KEY (category_id)
    REFERENCES categories(category_id)
) ENGINE=InnoDB;
```
- `-- ...` — разделители блока товаров.
- `CREATE TABLE products (` — начало создания таблицы товаров.
- `  product_id INT AUTO_INCREMENT PRIMARY KEY,` — автоинкрементный ключ товара.
- `  product_name VARCHAR(200) NOT NULL,` — обязательное название до 200 символов.
- `  category_id INT NOT NULL,` — обязательная ссылка на категорию.
- `  price DECIMAL(10,2) NOT NULL,` — обязательная цена с двумя знаками после запятой.
- `  stock_quantity INT DEFAULT 0,` — количество на складе, по умолчанию 0.
- `  average_rating DECIMAL(3,2) DEFAULT 0,` — средний рейтинг товара, стартует с 0.
- `  created_at DATE NOT NULL,` — дата добавления товара.
- `  CONSTRAINT fk_products_category` — имя внешнего ключа.
- `    FOREIGN KEY (category_id)` — поле связи.
- `    REFERENCES categories(category_id)` — ссылка на таблицу категорий.
- `) ENGINE=InnoDB;` — завершение определения.

### Таблица orders
```sql
-- =========================
-- orders
-- =========================
CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  order_date DATETIME NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  status ENUM('pending','processing','shipped','delivered','cancelled') DEFAULT 'pending',
  payment_method VARCHAR(50),
  CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id)
    REFERENCES users(user_id)
) ENGINE=InnoDB;
```
- `-- ...` — разделители блока заказов.
- `CREATE TABLE orders (` — начало таблицы заказов.
- `  order_id INT AUTO_INCREMENT PRIMARY KEY,` — автоинкрементный ключ заказа.
- `  user_id INT NOT NULL,` — ссылка на пользователя, обязательна.
- `  order_date DATETIME NOT NULL,` — дата и время заказа.
- `  total_amount DECIMAL(10,2) NOT NULL,` — сумма заказа.
- `  status ENUM('pending','processing','shipped','delivered','cancelled') DEFAULT 'pending',` — статус заказа с перечислением допустимых значений, по умолчанию `pending`.
- `  payment_method VARCHAR(50),` — метод оплаты, может быть NULL.
- `  CONSTRAINT fk_orders_user` — имя внешнего ключа на пользователей.
- `    FOREIGN KEY (user_id)` — поле связи.
- `    REFERENCES users(user_id)` — ссылка на таблицу `users`.
- `) ENGINE=InnoDB;` — завершение определения.

### Таблица order_items
```sql
-- =========================
-- order_items
-- =========================
CREATE TABLE order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  price_at_time DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id)
    REFERENCES products(product_id)
) ENGINE=InnoDB;
```
- `-- ...` — разделители блока строк заказов.
- `CREATE TABLE order_items (` — начало таблицы позиций заказов.
- `  order_item_id INT AUTO_INCREMENT PRIMARY KEY,` — автоинкрементный ключ позиции.
- `  order_id INT NOT NULL,` — ссылка на заказ, обязательна.
- `  product_id INT NOT NULL,` — ссылка на товар, обязательна.
- `  quantity INT NOT NULL,` — количество товара в позиции.
- `  price_at_time DECIMAL(10,2) NOT NULL,` — цена на момент покупки.
- `  CONSTRAINT fk_order_items_order` — имя внешнего ключа на заказы.
- `    FOREIGN KEY (order_id)` — поле связи.
- `    REFERENCES orders(order_id)` — ссылка на таблицу `orders`.
- `    ON DELETE CASCADE,` — при удалении заказа позиции удаляются автоматически.
- `  CONSTRAINT fk_order_items_product` — имя внешнего ключа на товары.
- `    FOREIGN KEY (product_id)` — поле связи.
- `    REFERENCES products(product_id)` — ссылка на таблицу `products`.
- `) ENGINE=InnoDB;` — завершение определения.

### Таблица reviews
```sql
-- =========================
-- reviews
-- =========================
CREATE TABLE reviews (
  review_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  rating INT CHECK (rating BETWEEN 1 AND 5),
  review_text TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  helpful_count INT DEFAULT 0,
  CONSTRAINT fk_reviews_user
    FOREIGN KEY (user_id)
    REFERENCES users(user_id),
  CONSTRAINT fk_reviews_product
    FOREIGN KEY (product_id)
    REFERENCES products(product_id),
  UNIQUE KEY uq_user_product (user_id, product_id)
) ENGINE=InnoDB;
```
- `-- ...` — разделители блока отзывов.
- `CREATE TABLE reviews (` — начало таблицы отзывов.
- `  review_id INT AUTO_INCREMENT PRIMARY KEY,` — автоинкрементный ключ отзыва.
- `  user_id INT NOT NULL,` — ссылка на пользователя, обязательна.
- `  product_id INT NOT NULL,` — ссылка на товар, обязательна.
- `  rating INT CHECK (rating BETWEEN 1 AND 5),` — оценка с ограничением 1–5.
- `  review_text TEXT,` — текст отзыва, может быть NULL.
- `  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,` — время создания, по умолчанию текущее.
- `  helpful_count INT DEFAULT 0,` — счётчик полезности, стартует с 0.
- `  CONSTRAINT fk_reviews_user` — имя внешнего ключа на пользователей.
- `    FOREIGN KEY (user_id)` — поле связи.
- `    REFERENCES users(user_id),` — ссылка на `users`, запятая продолжает список ограничений.
- `  CONSTRAINT fk_reviews_product` — имя внешнего ключа на товары.
- `    FOREIGN KEY (product_id)` — поле связи.
- `    REFERENCES products(product_id),` — ссылка на `products`.
- `  UNIQUE KEY uq_user_product (user_id, product_id)` — уникальная пара пользователь–товар (один отзыв на товар).
- `) ENGINE=InnoDB;` — завершение определения.

### Таблица monthly_reports
```sql
-- =========================
-- monthly_reports
-- =========================
CREATE TABLE monthly_reports (
  report_month DATE PRIMARY KEY,
  orders_count INT NOT NULL,
  revenue DECIMAL(12,2) NOT NULL,
  avg_check DECIMAL(12,2) NOT NULL,
  unique_buyers INT NOT NULL,
  items_sold INT NOT NULL,
  delivered_share DECIMAL(6,4) NOT NULL,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```
- `-- ...` — разделители блока отчётов.
- `CREATE TABLE monthly_reports (` — начало таблицы месячных отчётов.
- `  report_month DATE PRIMARY KEY,` — месяц отчёта как первичный ключ.
- `  orders_count INT NOT NULL,` — число заказов за месяц.
- `  revenue DECIMAL(12,2) NOT NULL,` — выручка за месяц.
- `  avg_check DECIMAL(12,2) NOT NULL,` — средний чек.
- `  unique_buyers INT NOT NULL,` — число уникальных покупателей.
- `  items_sold INT NOT NULL,` — количество проданных единиц.
- `  delivered_share DECIMAL(6,4) NOT NULL,` — доля доставленных заказов.
- `  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP` — время последнего обновления с дефолтом «сейчас».
- `    ON UPDATE CURRENT_TIMESTAMP` — при изменении строки поле обновляется автоматически.
- `) ENGINE=InnoDB;` — завершение определения.

### Индексы
```sql
-- =========================
-- indexes (analytics)
-- =========================
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_reviews_product ON reviews(product_id);
```
- `-- ...` — разделители блока индексов.
- `CREATE INDEX idx_orders_date ON orders(order_date);` — индекс по дате заказов для ускорения аналитики и фильтрации.
- `CREATE INDEX idx_orders_user ON orders(user_id);` — индекс по пользователю в заказах.
- `CREATE INDEX idx_products_category ON products(category_id);` — индекс по категории товаров.
- `CREATE INDEX idx_order_items_order ON order_items(order_id);` — индекс по заказу в позициях.
- `CREATE INDEX idx_order_items_product ON order_items(product_id);` — индекс по товару в позициях.
- `CREATE INDEX idx_reviews_product ON reviews(product_id);` — индекс по товару в отзывах.

## db/init/002_seed.sql

### Управление транзакцией и внешними ключами
```sql
SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;
```
- `SET FOREIGN_KEY_CHECKS = 0;` — временно отключает проверки внешних ключей, чтобы можно было залить данные в произвольном порядке.
- `START TRANSACTION;` — открывает транзакцию для пакетной вставки.

### Категории
```sql
-- =========================
-- categories
-- =========================
INSERT INTO categories (category_id, category_name, parent_category_id) VALUES
(1,'Электроника',NULL),
(2,'Смартфоны',1),
(3,'Ноутбуки',1),
(4,'Аксессуары',1),
(5,'Дом',NULL),
(6,'Кухня',5),
(7,'Уборка',5),
(8,'Спорт',NULL),
(9,'Фитнес',8),
(10,'Туризм',8),
(11,'Одежда',NULL),
(12,'Мужская',11),
(13,'Женская',11),
(14,'Детская',11),
(15,'Книги',NULL),
(16,'Худ. литература',15),
(17,'Нон-фикшн',15),
(18,'Игры',NULL),
(19,'Настольные',18),
(20,'Видеоигры',18);
```
- `-- ...` — разделители блока вставки категорий.
- `INSERT INTO categories (category_id, category_name, parent_category_id) VALUES` — начало массовой вставки с явным указанием столбцов.
- `(1,'Электроника',NULL),` — категория 1 «Электроника» без родителя.
- `(2,'Смартфоны',1),` — категория 2, дочерняя к 1.
- `(3,'Ноутбуки',1),` — категория 3, дочерняя к 1.
- `(4,'Аксессуары',1),` — категория 4, дочерняя к 1.
- `(5,'Дом',NULL),` — категория 5 верхнего уровня.
- `(6,'Кухня',5),` — категория 6, дочерняя к 5.
- `(7,'Уборка',5),` — категория 7, дочерняя к 5.
- `(8,'Спорт',NULL),` — категория 8 верхнего уровня.
- `(9,'Фитнес',8),` — категория 9, дочерняя к 8.
- `(10,'Туризм',8),` — категория 10, дочерняя к 8.
- `(11,'Одежда',NULL),` — категория 11 верхнего уровня.
- `(12,'Мужская',11),` — категория 12, дочерняя к 11.
- `(13,'Женская',11),` — категория 13, дочерняя к 11.
- `(14,'Детская',11),` — категория 14, дочерняя к 11.
- `(15,'Книги',NULL),` — категория 15 верхнего уровня.
- `(16,'Худ. литература',15),` — категория 16, дочерняя к 15.
- `(17,'Нон-фикшн',15),` — категория 17, дочерняя к 15.
- `(18,'Игры',NULL),` — категория 18 верхнего уровня.
- `(19,'Настольные',18),` — категория 19, дочерняя к 18.
- `(20,'Видеоигры',18);` — категория 20, дочерняя к 18; точка с запятой завершает оператор.

### Пользователи
```sql
-- =========================
-- users
-- =========================
INSERT INTO users (user_id, username, email, registration_date, city, total_orders, total_spent) VALUES
(1,'igor','igor@mail.com','2024-01-15','Zagreb',0,0),
(2,'anna','anna@mail.com','2024-02-10','Split',0,0),
(3,'marko','marko@mail.com','2024-03-05','Rijeka',0,0),
(4,'ivana','ivana@mail.com','2024-03-21','Osijek',0,0),
(5,'nika','nika@mail.com','2024-04-02','Zagreb',0,0),
(6,'ivan','ivan@mail.com','2024-04-19','Zadar',0,0),
(7,'petra','petra@mail.com','2024-05-11','Pula',0,0),
(8,'luka','luka@mail.com','2024-06-07','Zagreb',0,0),
(9,'maria','maria@mail.com','2024-06-22','Split',0,0),
(10,'dino','dino@mail.com','2024-07-03','Rijeka',0,0),
(11,'tea','tea@mail.com','2024-07-18','Zagreb',0,0),
(12,'filip','filip@mail.com','2024-08-01','Osijek',0,0),
(13,'sara','sara@mail.com','2024-08-14','Zadar',0,0),
(14,'tomislav','tomislav@mail.com','2024-09-09','Pula',0,0),
(15,'elena','elena@mail.com','2024-10-02','Zagreb',0,0),
(16,'matej','matej@mail.com','2024-10-21','Split',0,0),
(17,'karla','karla@mail.com','2024-11-03','Rijeka',0,0),
(18,'ante','ante@mail.com','2024-11-19','Osijek',0,0),
(19,'dorotea','dorotea@mail.com','2024-12-04','Zadar',0,0),
(20,'jana','jana@mail.com','2025-01-12','Zagreb',0,0);
```
- `-- ...` — разделители блока пользователей.
- `INSERT INTO users ... VALUES` — массовая вставка пользователей.
- `(1,'igor','igor@mail.com','2024-01-15','Zagreb',0,0),` — пользователь 1 с городом Загреб и нулями по статистике.
- `(2,'anna','anna@mail.com','2024-02-10','Split',0,0),` — пользователь 2 в Сплите.
- `(3,'marko','marko@mail.com','2024-03-05','Rijeka',0,0),` — пользователь 3 в Риеке.
- `(4,'ivana','ivana@mail.com','2024-03-21','Osijek',0,0),` — пользователь 4 в Осиеке.
- `(5,'nika','nika@mail.com','2024-04-02','Zagreb',0,0),` — пользователь 5 в Загребе.
- `(6,'ivan','ivan@mail.com','2024-04-19','Zadar',0,0),` — пользователь 6 в Задаре.
- `(7,'petra','petra@mail.com','2024-05-11','Pula',0,0),` — пользователь 7 в Пуле.
- `(8,'luka','luka@mail.com','2024-06-07','Zagreb',0,0),` — пользователь 8 в Загребе.
- `(9,'maria','maria@mail.com','2024-06-22','Split',0,0),` — пользователь 9 в Сплите.
- `(10,'dino','dino@mail.com','2024-07-03','Rijeka',0,0),` — пользователь 10 в Риеке.
- `(11,'tea','tea@mail.com','2024-07-18','Zagreb',0,0),` — пользователь 11 в Загребе.
- `(12,'filip','filip@mail.com','2024-08-01','Osijek',0,0),` — пользователь 12 в Осиеке.
- `(13,'sara','sara@mail.com','2024-08-14','Zadar',0,0),` — пользователь 13 в Задаре.
- `(14,'tomislav','tomislav@mail.com','2024-09-09','Pula',0,0),` — пользователь 14 в Пуле.
- `(15,'elena','elena@mail.com','2024-10-02','Zagreb',0,0),` — пользователь 15 в Загребе.
- `(16,'matej','matej@mail.com','2024-10-21','Split',0,0),` — пользователь 16 в Сплите.
- `(17,'karla','karla@mail.com','2024-11-03','Rijeka',0,0),` — пользователь 17 в Риеке.
- `(18,'ante','ante@mail.com','2024-11-19','Osijek',0,0),` — пользователь 18 в Осиеке.
- `(19,'dorotea','dorotea@mail.com','2024-12-04','Zadar',0,0),` — пользователь 19 в Задаре.
- `(20,'jana','jana@mail.com','2025-01-12','Zagreb',0,0);` — пользователь 20 в Загребе, завершающая строка блока.

### Товары
```sql
-- =========================
-- products
-- =========================
INSERT INTO products (product_id, product_name, category_id, price, stock_quantity, average_rating, created_at) VALUES
(1,'Smartphone A1',2,399.90,120,0,'2024-01-10'),
(2,'Smartphone A2',2,599.90,80,0,'2024-02-15'),
(3,'Laptop L1',3,999.00,40,0,'2024-03-01'),
(4,'Laptop L2',3,1299.00,25,0,'2024-05-10'),
(5,'Headphones H1',4,79.90,200,0,'2024-02-20'),
(6,'Charger C1',4,19.90,500,0,'2024-01-25'),
(7,'Blender B1',6,49.90,90,0,'2024-04-05'),
(8,'Coffee Maker K1',6,89.90,60,0,'2024-06-01'),
(9,'Vacuum V1',7,159.90,35,0,'2024-07-07'),
(10,'Detergent D1',7,9.90,300,0,'2024-05-20'),
(11,'Yoga Mat Y1',9,24.90,150,0,'2024-03-18'),
(12,'Dumbbells 2x5',9,39.90,110,0,'2024-08-12'),
(13,'Tent T1',10,129.90,30,0,'2024-09-01'),
(14,'Backpack P1',10,59.90,70,0,'2024-09-12'),
(15,'T-shirt M1',12,14.90,250,0,'2024-04-22'),
(16,'Dress W1',13,49.90,95,0,'2024-05-30'),
(17,'Kids Jacket KJ1',14,34.90,80,0,'2024-10-05'),
(18,'Novel N1',16,12.90,400,0,'2024-11-11'),
(19,'Nonfiction NF1',17,18.90,220,0,'2024-12-01'),
(20,'Board Game BG1',19,29.90,65,0,'2024-12-20');
```
- `-- ...` — разделители блока товаров.
- `INSERT INTO products ... VALUES` — массовая вставка товаров.
- `(1,'Smartphone A1',2,399.90,120,0,'2024-01-10'),` — товар 1, смартфон в категории 2, цена 399.90, склад 120, рейтинг 0, дата 10.01.2024.
- `(2,'Smartphone A2',2,599.90,80,0,'2024-02-15'),` — товар 2, смартфон A2, цена 599.90, склад 80.
- `(3,'Laptop L1',3,999.00,40,0,'2024-03-01'),` — товар 3, ноутбук L1, категория 3.
- `(4,'Laptop L2',3,1299.00,25,0,'2024-05-10'),` — товар 4, ноутбук L2.
- `(5,'Headphones H1',4,79.90,200,0,'2024-02-20'),` — товар 5, наушники, категория 4.
- `(6,'Charger C1',4,19.90,500,0,'2024-01-25'),` — товар 6, зарядка, цена 19.90, склад 500.
- `(7,'Blender B1',6,49.90,90,0,'2024-04-05'),` — товар 7, блендер, категория 6.
- `(8,'Coffee Maker K1',6,89.90,60,0,'2024-06-01'),` — товар 8, кофеварка.
- `(9,'Vacuum V1',7,159.90,35,0,'2024-07-07'),` — товар 9, пылесос, категория 7.
- `(10,'Detergent D1',7,9.90,300,0,'2024-05-20'),` — товар 10, средство для уборки.
- `(11,'Yoga Mat Y1',9,24.90,150,0,'2024-03-18'),` — товар 11, коврик для йоги.
- `(12,'Dumbbells 2x5',9,39.90,110,0,'2024-08-12'),` — товар 12, гантели.
- `(13,'Tent T1',10,129.90,30,0,'2024-09-01'),` — товар 13, палатка.
- `(14,'Backpack P1',10,59.90,70,0,'2024-09-12'),` — товар 14, рюкзак.
- `(15,'T-shirt M1',12,14.90,250,0,'2024-04-22'),` — товар 15, футболка.
- `(16,'Dress W1',13,49.90,95,0,'2024-05-30'),` — товар 16, платье.
- `(17,'Kids Jacket KJ1',14,34.90,80,0,'2024-10-05'),` — товар 17, детская куртка.
- `(18,'Novel N1',16,12.90,400,0,'2024-11-11'),` — товар 18, художественная книга.
- `(19,'Nonfiction NF1',17,18.90,220,0,'2024-12-01'),` — товар 19, нон-фикшн книга.
- `(20,'Board Game BG1',19,29.90,65,0,'2024-12-20');` — товар 20, настольная игра; завершающая строка.

### Заказы
```sql
-- =========================
-- orders
-- =========================
INSERT INTO orders (order_id, user_id, order_date, total_amount, status, payment_method) VALUES
(1,1,'2025-11-02 10:12:00',419.80,'delivered','card'),
(2,2,'2025-11-03 12:05:00',79.90,'delivered','card'),
(3,3,'2025-11-05 18:40:00',1048.80,'shipped','card'),
(4,4,'2025-11-07 09:25:00',49.90,'cancelled','cash'),
(5,5,'2025-11-10 14:10:00',169.80,'delivered','card'),
(6,6,'2025-11-12 16:00:00',24.90,'delivered','card'),
(7,7,'2025-11-15 11:30:00',89.90,'processing','card'),
(8,8,'2025-11-18 20:05:00',19.90,'delivered','card'),
(9,9,'2025-11-20 13:45:00',39.90,'delivered','cash'),
(10,10,'2025-11-22 08:10:00',59.90,'pending','card');
```
- `-- ...` — разделители блока заказов.
- `INSERT INTO orders ... VALUES` — массовая вставка заказов.
- `(1,1,'2025-11-02 10:12:00',419.80,'delivered','card'),` — заказ 1 от пользователя 1, сумма 419.80, доставлен, оплата картой.
- `(2,2,'2025-11-03 12:05:00',79.90,'delivered','card'),` — заказ 2, доставлен, оплата картой.
- `(3,3,'2025-11-05 18:40:00',1048.80,'shipped','card'),` — заказ 3, отправлен, оплата картой.
- `(4,4,'2025-11-07 09:25:00',49.90,'cancelled','cash'),` — заказ 4, отменён, оплата наличными.
- `(5,5,'2025-11-10 14:10:00',169.80,'delivered','card'),` — заказ 5, доставлен.
- `(6,6,'2025-11-12 16:00:00',24.90,'delivered','card'),` — заказ 6, доставлен.
- `(7,7,'2025-11-15 11:30:00',89.90,'processing','card'),` — заказ 7, в обработке.
- `(8,8,'2025-11-18 20:05:00',19.90,'delivered','card'),` — заказ 8, доставлен.
- `(9,9,'2025-11-20 13:45:00',39.90,'delivered','cash'),` — заказ 9, доставлен, оплата наличными.
- `(10,10,'2025-11-22 08:10:00',59.90,'pending','card');` — заказ 10, ожидает обработки; завершение блока.

### Позиции заказов
```sql
-- =========================
-- order_items
-- =========================
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price_at_time) VALUES
(1,1,1,1,399.90),
(2,1,6,1,19.90),
(3,2,5,1,79.90),
(4,3,3,1,999.00),
(5,3,5,1,79.90),
(6,3,6,1,19.90),
(7,4,7,1,49.90),
(8,5,9,1,159.90),
(9,5,6,1,19.90),
(10,6,11,1,24.90),
(11,7,8,1,89.90),
(12,8,6,1,19.90),
(13,9,12,1,39.90),
(14,10,14,1,59.90);
```
- `-- ...` — разделители блока позиций.
- `INSERT INTO order_items ... VALUES` — массовая вставка строк заказов.
- `(1,1,1,1,399.90),` — позиция 1 в заказе 1, товар 1, количество 1, цена 399.90.
- `(2,1,6,1,19.90),` — позиция 2 в заказе 1, товар 6.
- `(3,2,5,1,79.90),` — позиция 3 в заказе 2.
- `(4,3,3,1,999.00),` — позиция 4 в заказе 3, ноутбук 3.
- `(5,3,5,1,79.90),` — позиция 5 в заказе 3, наушники.
- `(6,3,6,1,19.90),` — позиция 6 в заказе 3, зарядка.
- `(7,4,7,1,49.90),` — позиция 7 в заказе 4.
- `(8,5,9,1,159.90),` — позиция 8 в заказе 5.
- `(9,5,6,1,19.90),` — позиция 9 в заказе 5.
- `(10,6,11,1,24.90),` — позиция 10 в заказе 6.
- `(11,7,8,1,89.90),` — позиция 11 в заказе 7.
- `(12,8,6,1,19.90),` — позиция 12 в заказе 8.
- `(13,9,12,1,39.90),` — позиция 13 в заказе 9.
- `(14,10,14,1,59.90);` — позиция 14 в заказе 10; завершение блока.

### Отзывы
```sql
-- =========================
-- reviews
-- =========================
INSERT INTO reviews (review_id, user_id, product_id, rating, review_text, created_at, helpful_count) VALUES
(1,1,1,5,'Отличный смартфон','2025-11-10 12:00:00',3),
(2,2,5,4,'Хороший звук','2025-11-12 09:10:00',1),
(3,3,3,5,'Ноутбук быстрый','2025-11-20 18:00:00',2),
(4,4,7,3,'Нормально','2025-11-08 10:00:00',0),
(5,5,9,5,'Мощный пылесос','2025-11-30 20:00:00',4),
(6,6,11,4,'Удобный коврик','2025-11-15 14:30:00',1),
(7,7,8,4,'Кофе вкусный','2025-12-02 08:10:00',0),
(8,8,6,5,'Дёшево и сердито','2025-11-19 11:45:00',2),
(9,9,12,4,'Гантели ок','2025-11-25 16:00:00',0),
(10,10,14,5,'Рюкзак удобный','2025-12-05 13:00:00',1);
```
- `-- ...` — разделители блока отзывов.
- `INSERT INTO reviews ... VALUES` — массовая вставка отзывов.
- `(1,1,1,5,'Отличный смартфон','2025-11-10 12:00:00',3),` — отзыв 1 от пользователя 1 на товар 1, оценка 5, текст «Отличный смартфон», дата, полезность 3.
- `(2,2,5,4,'Хороший звук','2025-11-12 09:10:00',1),` — отзыв 2 на товар 5, оценка 4, полезность 1.
- `(3,3,3,5,'Ноутбук быстрый','2025-11-20 18:00:00',2),` — отзыв 3 на товар 3.
- `(4,4,7,3,'Нормально','2025-11-08 10:00:00',0),` — отзыв 4 на товар 7, оценка 3.
- `(5,5,9,5,'Мощный пылесос','2025-11-30 20:00:00',4),` — отзыв 5 на товар 9, оценка 5.
- `(6,6,11,4,'Удобный коврик','2025-11-15 14:30:00',1),` — отзыв 6 на товар 11.
- `(7,7,8,4,'Кофе вкусный','2025-12-02 08:10:00',0),` — отзыв 7 на товар 8.
- `(8,8,6,5,'Дёшево и сердито','2025-11-19 11:45:00',2),` — отзыв 8 на товар 6.
- `(9,9,12,4,'Гантели ок','2025-11-25 16:00:00',0),` — отзыв 9 на товар 12.
- `(10,10,14,5,'Рюкзак удобный','2025-12-05 13:00:00',1);` — отзыв 10 на товар 14; завершающая строка.

### Завершение транзакции
```sql
COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
```
- `COMMIT;` — фиксирует все вставки в рамках транзакции.
- `SET FOREIGN_KEY_CHECKS = 1;` — включает обратно проверки внешних ключей.

## db/init/003_routines.sql

### Общие настройки
```sql
USE shop_analytics;
SET NAMES utf8mb4;
```
- `USE shop_analytics;` — выбирает БД перед созданием рутины.
- `SET NAMES utf8mb4;` — задаёт кодировку соединения для корректной работы с текстом.

### Функция calculate_user_rank
```sql
DELIMITER $$
CREATE FUNCTION calculate_user_rank(p_user_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE v_orders INT DEFAULT 0;
  DECLARE v_spent DECIMAL(12,2) DEFAULT 0;
  DECLARE v_reviews INT DEFAULT 0;
  DECLARE v_age_days INT DEFAULT 0;
  DECLARE v_score DECIMAL(12,4) DEFAULT 0;

  SELECT COUNT(*), COALESCE(SUM(total_amount),0)
  INTO v_orders, v_spent
  FROM orders
  WHERE user_id = p_user_id AND status <> 'cancelled';

  SELECT COUNT(*) INTO v_reviews
  FROM reviews WHERE user_id = p_user_id;

  SELECT DATEDIFF(CURDATE(), registration_date)
  INTO v_age_days
  FROM users WHERE user_id = p_user_id;

  SET v_score =
      LEAST(v_orders * 2, 20)
    + LEAST(v_spent / 100, 30)
    + LEAST(v_reviews * 1.5, 15)
    + LEAST(v_age_days / 90, 10);

  RETURN LEAST(10, GREATEST(1, FLOOR(v_score / 7.5) + 1));
END $$
```
- `DELIMITER $$` — меняет разделитель, чтобы тело функции могло содержать `;`.
- `CREATE FUNCTION calculate_user_rank(p_user_id INT)` — объявляет функцию с параметром `p_user_id`.
- `RETURNS INT` — функция возвращает целое.
- `DETERMINISTIC` — при одинаковых входных данных результат неизменен.
- `READS SQL DATA` — функция только читает данные.
- `BEGIN` — начало тела функции.
- `  DECLARE v_orders INT DEFAULT 0;` — локальная переменная заказов, старт 0.
- `  DECLARE v_spent DECIMAL(12,2) DEFAULT 0;` — сумма потраченных средств.
- `  DECLARE v_reviews INT DEFAULT 0;` — число отзывов.
- `  DECLARE v_age_days INT DEFAULT 0;` — возраст аккаунта в днях.
- `  DECLARE v_score DECIMAL(12,4) DEFAULT 0;` — суммарный скор.
- пустая строка — визуальный раздел.
- `  SELECT COUNT(*), COALESCE(SUM(total_amount),0)` — выбирает число заказов и сумму.
- `  INTO v_orders, v_spent` — сохраняет результаты в переменные.
- `  FROM orders` — источник данных — таблица заказов.
- `  WHERE user_id = p_user_id AND status <> 'cancelled';` — учитываются заказы пользователя без отменённых.
- пустая строка — раздел логических блоков.
- `  SELECT COUNT(*) INTO v_reviews` — считает отзывы пользователя и кладёт в `v_reviews`.
- `  FROM reviews WHERE user_id = p_user_id;` — выборка отзывов по пользователю.
- пустая строка — раздел.
- `  SELECT DATEDIFF(CURDATE(), registration_date)` — считает разницу в днях между сегодня и регистрацией.
- `  INTO v_age_days` — сохраняет в `v_age_days`.
- `  FROM users WHERE user_id = p_user_id;` — берёт дату регистрации нужного пользователя.
- пустая строка — раздел.
- `  SET v_score =` — начало вычисления итогового скора.
- `      LEAST(v_orders * 2, 20)` — добавляет вклад заказов, но ограничивает максимум 20.
- `    + LEAST(v_spent / 100, 30)` — добавляет вклад по сумме трат, потолок 30.
- `    + LEAST(v_reviews * 1.5, 15)` — вклад отзывов, максимум 15.
- `    + LEAST(v_age_days / 90, 10);` — вклад давности аккаунта, максимум 10.
- пустая строка — раздел.
- `  RETURN LEAST(10, GREATEST(1, FLOOR(v_score / 7.5) + 1));` — нормирует скор в ранги 1–10.
- `END $$` — закрывает тело функции с изменённым разделителем.

### Процедура generate_monthly_report
```sql
-- =========================
-- ПРОЦЕДУРА: месячный отчёт
-- =========================
CREATE PROCEDURE generate_monthly_report(IN p_month DATE)
BEGIN
  DECLARE v_start DATE;
  DECLARE v_end DATE;

  SET v_start = DATE_FORMAT(p_month, '%Y-%m-01');
  SET v_end = DATE_ADD(v_start, INTERVAL 1 MONTH);

  INSERT INTO monthly_reports
    (report_month, orders_count, revenue, avg_check,
     unique_buyers, items_sold, delivered_share)
  SELECT
    v_start,
    COUNT(*),
    SUM(total_amount),
    AVG(total_amount),
    COUNT(DISTINCT user_id),
    (
      SELECT SUM(oi.quantity)
      FROM order_items oi
      JOIN orders o2 ON o2.order_id = oi.order_id
      WHERE o2.status <> 'cancelled'
        AND o2.order_date >= v_start AND o2.order_date < v_end
    ),
    SUM(status='delivered') / COUNT(*)
  FROM orders
  WHERE status <> 'cancelled'
    AND order_date >= v_start AND order_date < v_end
  ON DUPLICATE KEY UPDATE
    orders_count = VALUES(orders_count),
    revenue = VALUES(revenue),
    avg_check = VALUES(avg_check),
    unique_buyers = VALUES(unique_buyers),
    items_sold = VALUES(items_sold),
    delivered_share = VALUES(delivered_share);

  SELECT * FROM monthly_reports WHERE report_month = v_start;
END $$
```
- `-- ...` — разделители блока процедуры.
- `CREATE PROCEDURE generate_monthly_report(IN p_month DATE)` — объявляет процедуру с входным параметром `p_month` (любая дата внутри месяца).
- `BEGIN` — начало тела процедуры.
- `  DECLARE v_start DATE;` — переменная начала месяца.
- `  DECLARE v_end DATE;` — переменная конца месяца.
- пустая строка — раздел.
- `  SET v_start = DATE_FORMAT(p_month, '%Y-%m-01');` — приводит вход к первому числу месяца.
- `  SET v_end = DATE_ADD(v_start, INTERVAL 1 MONTH);` — вычисляет начало следующего месяца.
- пустая строка — раздел.
- `  INSERT INTO monthly_reports` — вставка/обновление итогов в таблицу отчётов.
- `    (report_month, orders_count, revenue, avg_check,` — начало списка столбцов.
- `     unique_buyers, items_sold, delivered_share)` — продолжение списка столбцов.
- `  SELECT` — начало выборки для вставки.
- `    v_start,` — месяц отчёта как дата начала месяца.
- `    COUNT(*),` — число заказов за период.
- `    SUM(total_amount),` — суммарная выручка.
- `    AVG(total_amount),` — средний чек.
- `    COUNT(DISTINCT user_id),` — число уникальных покупателей.
- `    (` — начало подзапроса подсчёта штук.
- `      SELECT SUM(oi.quantity)` — сумма купленных единиц.
- `      FROM order_items oi` — подзапрос по позициям заказов.
- `      JOIN orders o2 ON o2.order_id = oi.order_id` — связывает позиции с заказами.
- `      WHERE o2.status <> 'cancelled'` — исключает отменённые заказы.
- `        AND o2.order_date >= v_start AND o2.order_date < v_end` — фильтр по выбранному месяцу.
- `    ),` — конец подзапроса, результат идёт в `items_sold`.
- `    SUM(status='delivered') / COUNT(*)` — доля доставленных заказов.
- `  FROM orders` — основная таблица для агрегатов.
- `  WHERE status <> 'cancelled'` — исключение отменённых.
- `    AND order_date >= v_start AND order_date < v_end` — ограничение по периоду.
- `  ON DUPLICATE KEY UPDATE` — при наличии строки за месяц выполняется обновление.
- `    orders_count = VALUES(orders_count),` — обновляет число заказов.
- `    revenue = VALUES(revenue),` — обновляет выручку.
- `    avg_check = VALUES(avg_check),` — обновляет средний чек.
- `    unique_buyers = VALUES(unique_buyers),` — обновляет уникальных покупателей.
- `    items_sold = VALUES(items_sold),` — обновляет количество единиц.
- `    delivered_share = VALUES(delivered_share);` — обновляет долю доставленных.
- пустая строка — раздел.
- `  SELECT * FROM monthly_reports WHERE report_month = v_start;` — возвращает подготовленный отчёт за месяц.
- `END $$` — завершение процедуры.

```sql
DELIMITER ;
```
- `DELIMITER ;` — возвращает стандартный разделитель `;` после объявления рутины.

## db/analytics/004_analytics.sql

```sql
USE shop_analytics;
```
- `USE shop_analytics;` — выбор базы перед аналитическими запросами.

### 1. Топ-5 товаров
```sql
SELECT p.product_name, SUM(oi.quantity) units_sold
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id AND o.status <> 'cancelled'
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC
LIMIT 5;
```
- `SELECT p.product_name, SUM(oi.quantity) units_sold` — выводит имя товара и количество проданных единиц (псевдоним `units_sold`).
- `FROM order_items oi` — старт выборки с таблицы позиций заказов.
- `JOIN orders o ON o.order_id = oi.order_id AND o.status <> 'cancelled'` — соединяет с заказами и фильтрует отменённые прямо в join.
- `JOIN products p ON p.product_id = oi.product_id` — подтягивает имена товаров.
- `GROUP BY p.product_name` — группирует продажи по товару.
- `ORDER BY units_sold DESC` — сортирует по убыванию продаж.
- `LIMIT 5;` — ограничивает выборку топ-5.

### 2. Топ пользователей за месяц
```sql
SELECT u.username, SUM(o.total_amount) spent
FROM orders o
JOIN users u ON u.user_id = o.user_id
WHERE o.order_date >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
  AND o.status <> 'cancelled'
GROUP BY u.username
ORDER BY spent DESC;
```
- `SELECT u.username, SUM(o.total_amount) spent` — выводит логин и сумму трат (`spent`).
- `FROM orders o` — основа выборки — заказы.
- `JOIN users u ON u.user_id = o.user_id` — присоединяет пользователей по id.
- `WHERE o.order_date >= DATE_SUB(NOW(), INTERVAL 1 MONTH)` — ограничивает заказы последним месяцем.
- `  AND o.status <> 'cancelled'` — исключает отменённые.
- `GROUP BY u.username` — агрегирует по пользователю.
- `ORDER BY spent DESC;` — сортирует по сумме трат по убыванию.

### 3. Средний чек по месяцам
```sql
SELECT DATE_FORMAT(order_date,'%Y-%m') month, AVG(total_amount) avg_check
FROM orders
WHERE status <> 'cancelled'
GROUP BY month;
```
- `SELECT DATE_FORMAT(order_date,'%Y-%m') month, AVG(total_amount) avg_check` — выводит месяц в формате ГГГГ-ММ и средний чек по нему.
- `FROM orders` — источник данных — заказы.
- `WHERE status <> 'cancelled'` — исключает отменённые.
- `GROUP BY month;` — группирует по вычисленному месяцу.

### 4. Товары, покупаемые вместе
```sql
SELECT oi1.product_id, oi2.product_id, COUNT(*) cnt
FROM order_items oi1
JOIN order_items oi2
  ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
GROUP BY oi1.product_id, oi2.product_id
ORDER BY cnt DESC;
```
- `SELECT oi1.product_id, oi2.product_id, COUNT(*) cnt` — выводит пары товаров и количество совместных покупок.
- `FROM order_items oi1` — первая копия таблицы позиций.
- `JOIN order_items oi2` — вторая копия для сочетаний.
- `  ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id` — соединяет позиции внутри одного заказа и оставляет пары в фиксированном порядке (без дублирования/самих себя).
- `GROUP BY oi1.product_id, oi2.product_id` — группирует по парам товаров.
- `ORDER BY cnt DESC;` — сортирует по убыванию частоты.

### 5. Воронка заказов
```sql
SELECT status, COUNT(*) cnt FROM orders GROUP BY status;
```
- `SELECT status, COUNT(*) cnt` — выводит статус и количество заказов в нём.
- `FROM orders` — источник данных.
- `GROUP BY status;` — группирует по статусу.

### 6. Выручка по категориям
```sql
SELECT c.category_name, SUM(oi.quantity * oi.price_at_time) revenue
FROM categories c
JOIN products p ON p.category_id = c.category_id
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id AND o.status <> 'cancelled'
GROUP BY c.category_name
ORDER BY revenue DESC;
```
- `SELECT c.category_name, SUM(oi.quantity * oi.price_at_time) revenue` — выводит имя категории и выручку из проданных товаров.
- `FROM categories c` — начало выборки с категорий.
- `JOIN products p ON p.category_id = c.category_id` — соединяет товары категории.
- `JOIN order_items oi ON oi.product_id = p.product_id` — подключает позиции заказов по товару.
- `JOIN orders o ON o.order_id = oi.order_id AND o.status <> 'cancelled'` — присоединяет заказы и отбрасывает отменённые.
- `GROUP BY c.category_name` — группирует агрегаты по категории.
- `ORDER BY revenue DESC;` — сортирует по выручке по убыванию.

### 7. Неактивные пользователи (30 дней)
```sql
SELECT u.username, MAX(o.order_date) last_order
FROM users u
LEFT JOIN orders o ON o.user_id = u.user_id
GROUP BY u.username
HAVING last_order IS NULL OR last_order < DATE_SUB(NOW(), INTERVAL 30 DAY);
```
- `SELECT u.username, MAX(o.order_date) last_order` — выводит пользователя и дату его последнего заказа (`NULL`, если заказов нет).
- `FROM users u` — базовая таблица — пользователи.
- `LEFT JOIN orders o ON o.user_id = u.user_id` — присоединяет заказы, но сохраняет пользователей без заказов.
- `GROUP BY u.username` — группирует для вычисления MAX по пользователю.
- `HAVING last_order IS NULL OR last_order < DATE_SUB(NOW(), INTERVAL 30 DAY);` — оставляет тех, у кого нет заказов или последний заказ старше 30 дней.

### 8. Сезонность продаж
```sql
SELECT DATE_FORMAT(order_date,'%Y-%m') month, SUM(total_amount) revenue
FROM orders
WHERE status <> 'cancelled'
GROUP BY month;
```
- `SELECT DATE_FORMAT(order_date,'%Y-%m') month, SUM(total_amount) revenue` — выводит месяц и суммарную выручку.
- `FROM orders` — источник — заказы.
- `WHERE status <> 'cancelled'` — исключает отменённые.
- `GROUP BY month;` — группирует по месяцу.

### 9. Рейтинг городов
```sql
SELECT city, COUNT(*) users_cnt
FROM users
GROUP BY city
ORDER BY users_cnt DESC;
```
- `SELECT city, COUNT(*) users_cnt` — выводит город и количество пользователей.
- `FROM users` — источник — таблица пользователей.
- `GROUP BY city` — группирует по городу.
- `ORDER BY users_cnt DESC;` — сортирует по убыванию количества.

### 10. Ранг пользователей
```sql
SELECT username, calculate_user_rank(user_id) AS user_rank
FROM users
ORDER BY user_rank DESC;
```
- `SELECT username, calculate_user_rank(user_id) AS user_rank` — выводит логин и вычисленный ранг через функцию `calculate_user_rank`.
- `FROM users` — данные берутся из таблицы пользователей.
- `ORDER BY user_rank DESC;` — сортировка по рангу по убыванию.


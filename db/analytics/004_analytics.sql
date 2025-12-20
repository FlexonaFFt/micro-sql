USE shop_analytics;

-- 1. Топ-5 товаров
SELECT p.product_name, SUM(oi.quantity) units_sold
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id AND o.status <> 'cancelled'
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC
LIMIT 5;

-- 2. Топ пользователей за месяц
SELECT u.username, SUM(o.total_amount) spent
FROM orders o
JOIN users u ON u.user_id = o.user_id
WHERE o.order_date >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
  AND o.status <> 'cancelled'
GROUP BY u.username
ORDER BY spent DESC;

-- 3. Средний чек по месяцам
SELECT DATE_FORMAT(order_date,'%Y-%m') month, AVG(total_amount) avg_check
FROM orders
WHERE status <> 'cancelled'
GROUP BY month;

-- 4. Товары, покупаемые вместе
SELECT oi1.product_id, oi2.product_id, COUNT(*) cnt
FROM order_items oi1
JOIN order_items oi2
  ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
GROUP BY oi1.product_id, oi2.product_id
ORDER BY cnt DESC;

-- 5. Воронка заказов
SELECT status, COUNT(*) cnt FROM orders GROUP BY status;

-- 6. Выручка по категориям
SELECT c.category_name, SUM(oi.quantity * oi.price_at_time) revenue
FROM categories c
JOIN products p ON p.category_id = c.category_id
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id AND o.status <> 'cancelled'
GROUP BY c.category_name
ORDER BY revenue DESC;

-- 7. Неактивные пользователи (30 дней)
SELECT u.username, MAX(o.order_date) last_order
FROM users u
LEFT JOIN orders o ON o.user_id = u.user_id
GROUP BY u.username
HAVING last_order IS NULL OR last_order < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- 8. Сезонность продаж
SELECT DATE_FORMAT(order_date,'%Y-%m') month, SUM(total_amount) revenue
FROM orders
WHERE status <> 'cancelled'
GROUP BY month;

-- 9. Рейтинг городов
SELECT city, COUNT(*) users_cnt
FROM users
GROUP BY city
ORDER BY users_cnt DESC;

-- 10. Ранг пользователей
SELECT username, calculate_user_rank(user_id) AS user_rank
FROM users
ORDER BY user_rank DESC;

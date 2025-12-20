USE shop_analytics;
SET NAMES utf8mb4;

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

DELIMITER ;
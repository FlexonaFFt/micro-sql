CREATE DATABASE IF NOT EXISTS shop_analytics
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE shop_analytics;

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

-- =========================
-- indexes (analytics)
-- =========================
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_reviews_product ON reviews(product_id);
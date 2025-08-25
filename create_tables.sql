-- Nine27 Pharmacy Database Setup
-- Run this in your MySQL client or phpMyAdmin

USE nine27_pharmacy;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    mobile VARCHAR(20),
    address TEXT,
    remember_token VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    image VARCHAR(255),
    category VARCHAR(100) NOT NULL,
    brand VARCHAR(100),
    sku VARCHAR(100) UNIQUE,
    stock_quantity INT DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    requires_prescription BOOLEAN DEFAULT FALSE,
    dosage VARCHAR(50),
    active_ingredient VARCHAR(255),
    manufacturer VARCHAR(255),
    expiry_date DATE,
    rating DECIMAL(3,1),
    review_count INT DEFAULT 0,
    tags JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_available (is_available),
    INDEX idx_prescription (requires_prescription),
    INDEX idx_category_available (category, is_available),
    INDEX idx_rating (rating, review_count)
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL,
    items_count INT NOT NULL,
    order_type VARCHAR(50) DEFAULT 'regular',
    category VARCHAR(100),
    delivery_address TEXT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_order_number (order_number)
);

-- Create order_items table
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    product_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    product_image VARCHAR(255),
    product_description TEXT,
    product_category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id)
);

-- Insert sample products
DELETE FROM products;

INSERT INTO products (name, description, price, image, category, brand, sku, stock_quantity, is_available, requires_prescription, dosage, active_ingredient, manufacturer, rating, review_count, tags) VALUES
-- Medicines
('Biogesic 500mg', 'Paracetamol 500mg tablet for fever and pain relief', 50.00, 'assets/img/biogesic.jpg', 'medicines', 'Unilab', 'BIO-500-20', 150, 1, 0, '500mg', 'Paracetamol', 'Unilab', 4.5, 128, '["pain relief", "fever", "headache"]'),
('Advil 200mg', 'Ibuprofen tablets for pain relief and inflammation', 75.00, 'assets/img/advil.jpg', 'medicines', 'Pfizer', 'ADV-200-20', 120, 1, 0, '200mg', 'Ibuprofen', 'Pfizer', 4.4, 95, '["pain relief", "inflammation", "fever"]'),
('Tylenol 500mg', 'Acetaminophen tablets for fever and pain relief', 65.00, 'assets/img/tylenol.jpg', 'medicines', 'Johnson & Johnson', 'TYL-500-24', 80, 1, 0, '500mg', 'Acetaminophen', 'Johnson & Johnson', 4.6, 142, '["pain relief", "fever", "safe"]'),
('Aspirin 325mg', 'Low-dose aspirin for heart health and pain relief', 35.00, 'assets/img/aspirin.jpg', 'medicines', 'Bayer', 'ASP-325-100', 200, 1, 0, '325mg', 'Acetylsalicylic Acid', 'Bayer', 4.3, 78, '["heart health", "pain relief", "blood thinner"]'),
('Mefenamic Acid 500mg', 'Anti-inflammatory medicine for pain and fever', 45.00, 'assets/img/mefenamic.jpg', 'medicines', 'Generics', 'MEF-500-10', 90, 1, 0, '500mg', 'Mefenamic Acid', 'Generics Pharmacy', 4.2, 67, '["pain relief", "inflammation", "menstrual pain"]'),

-- Vitamins
('Vitamin C 500mg', 'High-potency Vitamin C supplement for immune system support', 15.00, 'assets/img/vitamin-c.jpg', 'vitamins', 'Centrum', 'VIT-C-500-30', 200, 1, 0, '500mg', 'Ascorbic Acid', 'Pfizer', 4.3, 89, '["vitamin", "immunity", "antioxidant"]'),
('Multivitamins Complete', 'Complete daily multivitamin with minerals', 450.00, 'assets/img/multivitamins.jpg', 'vitamins', 'Centrum', 'MUL-COM-30', 60, 1, 0, NULL, NULL, 'Pfizer', 4.5, 203, '["multivitamin", "daily nutrition", "minerals"]'),
('Vitamin D3 1000IU', 'High-potency Vitamin D3 for bone health', 320.00, 'assets/img/vitamin-d3.jpg', 'vitamins', 'Nature Made', 'VIT-D3-1000-60', 90, 1, 0, '1000IU', 'Cholecalciferol', 'Nature Made', 4.7, 156, '["vitamin d", "bone health", "immunity"]'),
('Omega-3 Fish Oil', 'Premium fish oil capsules for heart and brain health', 680.00, 'assets/img/omega3.jpg', 'vitamins', 'Nordic Naturals', 'OME-3-120', 45, 1, 0, NULL, NULL, 'Nordic Naturals', 4.8, 234, '["omega 3", "heart health", "brain health"]'),
('Calcium + Vitamin D', 'Calcium supplement with Vitamin D for bone strength', 280.00, 'assets/img/calcium.jpg', 'vitamins', 'Caltrate', 'CAL-VD-60', 75, 1, 0, NULL, NULL, 'Pfizer', 4.4, 112, '["calcium", "bone health", "vitamin d"]'),

-- First Aid
('Betadine Solution 60ml', 'Antiseptic solution for wound cleaning and disinfection', 85.00, 'assets/img/betadine.jpg', 'first_aid', 'Betadine', 'BET-SOL-60', 75, 1, 0, NULL, 'Povidone Iodine', 'Mundipharma', 4.7, 156, '["antiseptic", "wound care", "disinfectant"]'),
('Alcohol 70% 500ml', 'Isopropyl alcohol for disinfection and cleaning', 45.00, 'assets/img/alcohol.jpg', 'first_aid', 'Green Cross', 'ALC-70-500', 150, 1, 0, NULL, 'Isopropyl Alcohol', 'Green Cross', 4.2, 67, '["disinfectant", "cleaning", "antiseptic"]'),
('Band-Aid Adhesive Bandages', 'Sterile adhesive bandages for wound protection', 125.00, 'assets/img/bandaid.jpg', 'first_aid', 'Band-Aid', 'BND-AID-50', 200, 1, 0, NULL, NULL, 'Johnson & Johnson', 4.6, 189, '["bandages", "wound care", "first aid"]'),
('Hydrogen Peroxide 3%', 'Antiseptic solution for wound cleaning', 35.00, 'assets/img/hydrogen-peroxide.jpg', 'first_aid', 'Generic', 'HYD-PER-250', 100, 1, 0, NULL, 'Hydrogen Peroxide', 'Generic Pharma', 4.1, 45, '["antiseptic", "wound cleaning", "disinfectant"]'),

-- Prescription Drugs
('Amoxicillin 500mg', 'Antibiotic capsule for bacterial infections', 25.00, 'assets/img/amoxicillin.jpg', 'prescription_drugs', 'Generics', 'AMX-500-21', 100, 1, 1, '500mg', 'Amoxicillin', 'Generics Pharmacy', 4.2, 67, '["antibiotic", "infection", "prescription"]'),
('Losartan 50mg', 'ACE inhibitor for high blood pressure', 180.00, 'assets/img/losartan.jpg', 'prescription_drugs', 'Generics', 'LOS-50-30', 60, 1, 1, '50mg', 'Losartan Potassium', 'Generics Pharmacy', 4.4, 89, '["blood pressure", "hypertension", "prescription"]'),
('Metformin 500mg', 'Diabetes medication for blood sugar control', 95.00, 'assets/img/metformin.jpg', 'prescription_drugs', 'Generics', 'MET-500-30', 80, 1, 1, '500mg', 'Metformin HCl', 'Generics Pharmacy', 4.3, 112, '["diabetes", "blood sugar", "prescription"]');

-- Show results
SELECT 'Database setup complete!' as status;
SELECT category, COUNT(*) as count FROM products GROUP BY category;
SELECT 'Total products:', COUNT(*) as total FROM products;
-- Crear la base de datos
CREATE DATABASE customer_analysis;

-- Conectarse a la base de datos
\c customer_analysis

-- Crear tabla clients
CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    industry VARCHAR(100) NOT NULL,
    contact_info VARCHAR(255) NOT NULL
);

-- Crear tabla interactions
CREATE TABLE interactions (
    interaction_id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES clients(client_id),
    date DATE NOT NULL,
    interaction_type VARCHAR(100) NOT NULL
);

-- Crear tabla sales
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES clients(client_id),
    sale_amount DECIMAL(10,2) NOT NULL,
    sale_date DATE NOT NULL
);

-- Crear índices para mejorar el rendimiento
CREATE INDEX idx_interactions_client_id ON interactions(client_id);
CREATE INDEX idx_sales_client_id ON sales(client_id);
CREATE INDEX idx_sales_date ON sales(sale_date);

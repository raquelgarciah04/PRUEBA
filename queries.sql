-- 1. Consulta para contar la cantidad total de interacciones por cliente
SELECT 
    c.client_id,
    c.client_name,
    COUNT(i.interaction_id) AS total_interactions
FROM 
    clients c
LEFT JOIN 
    interactions i ON c.client_id = i.client_id
GROUP BY 
    c.client_id, c.client_name
ORDER BY 
    total_interactions DESC;

-- 2. Consulta para sumar el total de ventas por cliente y por industria
SELECT 
    c.client_id,
    c.client_name,
    c.industry,
    COALESCE(SUM(s.sale_amount), 0) AS total_sales
FROM 
    clients c
LEFT JOIN 
    sales s ON c.client_id = s.client_id
GROUP BY 
    c.client_id, c.client_name, c.industry
ORDER BY 
    total_sales DESC;

-- 3. Consulta para listar todas las interacciones y ventas para un cliente específico (Tech Solutions Inc.)
SELECT 
    'Interaction' AS record_type,
    i.date,
    i.interaction_type,
    NULL AS sale_amount
FROM 
    interactions i
JOIN 
    clients c ON i.client_id = c.client_id
WHERE 
    c.client_name = 'Tech Solutions Inc.'

UNION ALL

SELECT 
    'Sale' AS record_type,
    s.sale_date AS date,
    NULL AS interaction_type,
    s.sale_amount
FROM 
    sales s
JOIN 
    clients c ON s.client_id = c.client_id
WHERE 
    c.client_name = 'Tech Solutions Inc.'
ORDER BY 
    date;

-- 4. Consulta para determinar el promedio mensual de ventas y compararlo con el mes anterior
WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        SUM(sale_amount) AS total_sales,
        COUNT(sale_id) AS sales_count
    FROM 
        sales
    GROUP BY 
        year, month
    ORDER BY 
        year, month
)

SELECT 
    year,
    month,
    total_sales,
    sales_count,
    total_sales / NULLIF(sales_count, 0) AS avg_sale_amount,
    LAG(total_sales, 1) OVER (ORDER BY year, month) AS previous_month_sales,
    total_sales - LAG(total_sales, 1) OVER (ORDER BY year, month) AS sales_difference,
    ROUND((total_sales - LAG(total_sales, 1) OVER (ORDER BY year, month)) / 
    NULLIF(LAG(total_sales, 1) OVER (ORDER BY year, month), 0) * 100, 2) AS percentage_change
FROM 
    monthly_sales;

-- 5. Consulta con JOINs para mostrar un resumen completo de la actividad del cliente
SELECT 
    c.client_id,
    c.client_name,
    c.industry,
    COUNT(DISTINCT i.interaction_id) AS total_interactions,
    COUNT(DISTINCT s.sale_id) AS total_sales,
    COALESCE(SUM(s.sale_amount), 0) AS total_sales_amount,
    ROUND(COALESCE(SUM(s.sale_amount), 0) / NULLIF(COUNT(DISTINCT s.sale_id), 0), 2) AS avg_sale_amount
FROM 
    clients c
LEFT JOIN 
    interactions i ON c.client_id = i.client_id
LEFT JOIN 
    sales s ON c.client_id = s.client_id
GROUP BY 
    c.client_id, c.client_name, c.industry
ORDER BY 
    total_sales_amount DESC;

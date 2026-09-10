-- Cantidad de publicaciones por estado
SELECT state, COUNT(*) 
FROM posts  
GROUP BY state;

-- Cantidad de vehiculos publicaciones por marca
SELECT vehicles.brand, COUNT(*)
FROM posts
JOIN vehicles ON posts.vehicle_id = vehicles.id
GROUP BY vehicles.brand;

-- Precio promeido por marca
SELECT brand, AVG(posts.price)
FROM posts
JOIN vehicles ON posts.vehicle_id = vehicles.id
GROUP BY brand;

-- Top 10 vendedores con mas publicaciones
SELECT seller_id, COUNT(*)
FROM posts
GROUP BY seller_id
ORDER BY COUNT(*) DESC
LIMIT 10;

---- Query para reporte de usuario ----

SELECT users.name,
    (SELECT COUNT(*) FROM posts
    WHERE seller_id = $1) AS posts, -- Publicaciones de un usario ($1 usuario)
    
    (SELECT COUNT(*) FROM posts
    WHERE seller_id = $1 AND state = 0) AS active_posts, -- Publicaciones activas, pausadas, finalizadas ($1 usuario, $2 estado)

    (SELECT COUNT(*) FROM transactions t
    JOIN posts p ON t.post_id = p.id
    WHERE p.seller_id = $1) AS sales, -- Cantidad de ventas

    COALESCE((SELECT SUM(t.sale_price) FROM transactions t
    JOIN posts p ON t.post_id = p.id
    WHERE p.seller_id = $1), 0) AS billing, -- Dinero generado

    (SELECT COUNT(*) FROM transactions
    WHERE buyer_id = $1) AS purchases, -- Cantidad de compras

    COALESCE((SELECT SUM(sale_price) FROM transactions
    WHERE buyer_id = $1), 0) AS spent, -- Valor de las compras

    (SELECT COUNT(*) FROM posts
    WHERE seller_id = $1 AND state = 0 AND create_time < NOW() - INTERVAL '6 months') AS old_posts -- Posts con antiguedad
FROM users
WHERE users.id = $1;

SELECT * FROM posts WHERE seller_id = 4180 -- Usuario para pruebas

/*
EJEMPLO:
Usuario: Juan Pérez 4180
────────────────────────
Publicaciones:          27 Hecho
Publicaciones activas:  12 Hecho
Ventas:                  9 Hecho
Facturación:       $145.000 Hecho
Compras:                 2 Hecho
Monto total gastado:      $31.000 Hecho 
Publicaciones antiguas: 2 Hecho
*\
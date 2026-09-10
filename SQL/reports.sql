-- Cantidad de publicaciones por estado
SELECT state, COUNT(*) AS total
FROM posts  
GROUP BY state;

-- Precio promeido por marca
SELECT brand, ROUND(AVG(p.price), 2) AS average
FROM posts p
JOIN vehicles v ON p.vehicle_id = v.id
GROUP BY brand;

-- Top 10 vendedores con mas publicaciones
SELECT u.name, p.seller_id, COUNT(*) AS total
FROM posts p
JOIN users u ON p.seller_id = u.id 
GROUP BY u.name, p.seller_id
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Ordenar posts por precio descendiente o ascendiente
SELECT id, price FROM posts
ORDER BY price; --DESC

-- Buscar modelo en rango de precio
SELECT v.brand, v.model, p.price, p.id FROM posts p
JOIN vehicles v ON p.vehicle_id = v.id
WHERE p.state = 0 AND v.brand = 'Toyota' AND p.price BETWEEN 20000 AND 50000
ORDER BY p.price;

-- Publicado hace menos de 1 mes (cambiar tiempo segun busqueda)
SELECT * FROM posts
WHERE state = 0 AND create_time > NOW() - INTERVAL '1 month'
ORDER BY create_time DESC;

-- Promedio de km por marca
SELECT v.brand, ROUND(AVG(v.km), 0) FROM posts p
JOIN vehicles v ON p.vehicle_id = v.id
WHERE p.state = 0
GROUP BY brand;

-- Cantidad de vehiculos publicaciones por marca
SELECT v.brand, COUNT(*) AS total
FROM posts p
JOIN vehicles v ON p.vehicle_id = v.id
GROUP BY v.brand;

-- Cantidad de vehiculos publicaciones por marca (filtrado por estado 4180)
SELECT v.brand, COUNT(*) AS total
FROM posts p
JOIN vehicles v ON p.vehicle_id = v.id
WHERE p.state = 4180
GROUP BY v.brand;

-- Marcas con muchos posts
SELECT v.brand, COUNT(*) AS activ_posts FROM posts p
JOIN vehicles v ON p.vehicle_id = v.id
WHERE state = 0
GROUP BY v.brand
HAVING COUNT(*) > 12050;

-- Usuarios sin publicaciones
SELECT u.* FROM users u
LEFT JOIN posts p ON p.seller_id = u.id
WHERE p.id IS NULL;

-- Post + sus imagenes  4180 post)
SELECT p.id AS post_id, i.id AS image_id, i.is_cover FROM posts p
JOIN images i ON p.id = i.post_id
WHERE p.id = 4180;

---- Query para reporte de usuario ----
SELECT users.name,
    (SELECT COUNT(*) FROM posts
    WHERE seller_id = 4180) AS posts, -- Publicaciones de un usario  4180 usuario)
    
    (SELECT COUNT(*) FROM posts
    WHERE seller_id = 4180 AND state = 0) AS active_posts, -- Publicaciones, elegir si activas, pausadas, eliminadas, finalizadas con $2  4180 usuario, $2 estado)

    (SELECT COUNT(*) FROM transactions t
    JOIN posts p ON t.post_id = p.id
    WHERE p.seller_id = 4180) AS sales, -- Cantidad de ventas

    COALESCE((SELECT SUM(t.sale_price) FROM transactions t
    JOIN posts p ON t.post_id = p.id
    WHERE p.seller_id = 4180), 0) AS billing, -- Dinero generado

    (SELECT COUNT(*) FROM transactions
    WHERE buyer_id = 4180) AS purchases, -- Cantidad de compras

    COALESCE((SELECT SUM(sale_price) FROM transactions
    WHERE buyer_id = 4180), 0) AS spent, -- Valor de las compras

    (SELECT COUNT(*) FROM posts
    WHERE seller_id = 4180 AND state = 0 AND create_time < NOW() - INTERVAL '6 months') AS old_posts -- Posts con antiguedad
FROM users
WHERE users.id = 4180;

--general
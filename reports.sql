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

-- Publicaciones de un usario ($1 usuario)
SELECT users.name, COUNT(*) AS posts
FROM posts
JOIN users ON posts.seller_id = users.id
WHERE users.id = $1
GROUP BY users.name;

-- Publicaciones activas ($1 usuario, $2 estado)
SELECT COUNT(*) AS active_posts
FROM posts
JOIN users ON posts.seller_id = users.id
WHERE users.id = 4180 AND posts.state = 0
GROUP BY users.name;

SELECT COUNT(*) AS sells
FROM posts
JOIN users ON posts.seller_id = users.id
WHERE users.id = 4180 AND posts.state = 2



/*
Usuario: Juan Pérez
────────────────────────
Publicaciones:          27
Publicaciones activas:  12
Vehículos vendidos:      9
Precio promedio:     $18.500

Ventas:                  9
Facturación:       $145.000
Venta promedio:     $16.100

Compras:                 2
Dinero gastado:      $31.000*\
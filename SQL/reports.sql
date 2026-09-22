
-- =========================================================
-- ACCIONES DEL VENDEDOR
-- Insert / Update / Delete
-- =========================================================

-- Crear una nueva publicacion (datos de ejemplo)
INSERT INTO posts (title, decription, url, price, vehicle_id, seller_id, state)
VALUES ('Post de testing', 'Descripcion', 'url del post', 20000, 1, 4180, 0);

-- Editar precio del post
UPDATE posts
SET price = 18000
WHERE id = $1

-- Pausar post
UPDATE posts
SET state = 1
WHERE id = $1

-- Eliminar imagen
DELETE FROM images
WHERE id = $1

-- =========================================================
-- BUSQUEDA / BROWSE
-- Lo que ve un comprador navegando y filtrando publicaciones
-- =========================================================

-- Buscar modelo en rango de precio
SELECT v.brand, v.model, p.price, p.id FROM posts p
JOIN vehicles v ON p.vehicle_id = v.id
WHERE p.state = 0 AND v.brand = 'Toyota' AND p.price BETWEEN 20000 AND 50000
ORDER BY p.price;

-- Ordenar posts por precio descendiente o ascendiente
SELECT id, price FROM posts
ORDER BY price; --DESC

-- Publicado hace menos de 1 mes (cambiar tiempo segun busqueda)
SELECT * FROM posts
WHERE state = 0 AND create_time > NOW() - INTERVAL '1 month'
ORDER BY create_time DESC;

-- =========================================================
-- DETALLE DE PUBLICACION
-- Al abrir un post especifico ($1 = id del post)
-- =========================================================

-- Post + imagenes
SELECT p.id AS post_id, i.id AS image_id, i.is_cover FROM posts p
JOIN images i ON p.id = i.post_id
WHERE p.id = $1;

-- =========================================================
-- PERFIL DE VENDEDOR
-- Dashboard que ve un vendedor de su cuenta
-- ($1 = id de usuario, $2 = estado)
-- =========================================================

SELECT users.name,
    (SELECT COUNT(*) FROM posts
    WHERE seller_id = $1) AS posts, -- Publicaciones del usuario

    (SELECT COUNT(*) FROM posts
    WHERE seller_id = $1 AND state = $2) AS active_posts, -- Publicaciones en el estado $2

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

-- =========================================================
-- PANEL DE ADMINISTRACION / ANALYTICS
-- Metricas internas
-- =========================================================

-- Cantidad de publicaciones por estado
SELECT state, COUNT(*) AS total
FROM posts
GROUP BY state;

-- Precio promedio por marca
SELECT brand, ROUND(AVG(p.price), 2) AS average
FROM posts p
JOIN vehicles v ON p.vehicle_id = v.id
GROUP BY brand;

-- Promedio de km por marca
SELECT v.brand, ROUND(AVG(v.km), 0) AS avg_km FROM posts p
JOIN vehicles v ON p.vehicle_id = v.id
WHERE p.state = 0
GROUP BY brand;

-- Cantidad de publicaciones por marca
SELECT v.brand, COUNT(*) AS total
FROM posts p
JOIN vehicles v ON p.vehicle_id = v.id
GROUP BY v.brand;

-- Cantidad de publicaciones por marca (filtrado por estado $1)
SELECT v.brand, COUNT(*) AS total
FROM posts p
JOIN vehicles v ON p.vehicle_id = v.id
WHERE p.state = $1
GROUP BY v.brand;

-- Marcas con mas posts que $1
SELECT v.brand, COUNT(*) AS activ_posts FROM posts p
JOIN vehicles v ON p.vehicle_id = v.id
WHERE state = 0
GROUP BY v.brand
HAVING COUNT(*) > $1;

-- Top 10 vendedores con mas publicaciones
SELECT u.name, p.seller_id, COUNT(*) AS total
FROM posts p
JOIN users u ON p.seller_id = u.id
GROUP BY u.name, p.seller_id
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Ranking de vendedores por facturacion total
WITH seller_revenue AS (
    SELECT p.seller_id, SUM(t.sale_price) AS total_revenue, COUNT(*) AS sales
    FROM transactions t
    JOIN posts p ON p.id = t.post_id
    GROUP BY p.seller_id
)
SELECT
    seller_id,
    total_revenue,
    sales,
    RANK() OVER (ORDER BY total_revenue DESC) AS rank
FROM seller_revenue
ORDER BY rank
LIMIT 20;

-- Usuarios sin publicaciones
SELECT u.* FROM users u
LEFT JOIN posts p ON p.seller_id = u.id
WHERE p.id IS NULL;
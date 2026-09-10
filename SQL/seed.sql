-- =========================================================
-- SEED DATA - Curpo
-- Genera datos de prueba con distribución no homogénea
-- para que las queries de reporte y los índices tengan
-- sentido al medir con EXPLAIN ANALYZE.
-- =========================================================

BEGIN;

---------- VEHICLES ----------
INSERT INTO vehicles (brand, model, used, km, specs)
SELECT
    brand,
    model,
    used,
    CASE WHEN used
         THEN floor(random() * 200000)::int   -- usado: 0 a 200.000 km
         ELSE floor(random() * 100)::int       -- 0km: casi sin km
    END,
    specs
FROM (
    SELECT
        (ARRAY['Toyota','Volkswagen','Chevrolet','Ford','Fiat','Renault','Peugeot','Nissan','Honda','Hyundai'])[floor(random()*10)+1] AS brand,
        (ARRAY['Corolla','Gol','Onix','Focus','Cronos','Sandero','208','Versa','Civic','HB20'])[floor(random()*10)+1] AS model,
        random() < 0.85 AS used,
        jsonb_build_object(
            'color', (ARRAY['blanco','negro','gris','rojo','azul'])[floor(random()*5)+1],
            'transmision', (ARRAY['manual','automatica'])[floor(random()*2)+1],
            'combustible', (ARRAY['nafta','diesel','hibrido','electrico'])[floor(random()*4)+1],
            'puertas', (ARRAY[2,4])[floor(random()*2)+1]
        ) AS specs
    FROM generate_series(1, 200000)
) g;

-- ---------- USERS ----------
INSERT INTO users (name, mail, phone)
SELECT
    'user_' || gs,
    'user' || gs || '@mail.com',
    '09' || (10000000 + floor(random()*89999999))::text
FROM generate_series(1, 15000) gs;

-- ---------- POSTS ----------
-- 1 post por vehicle (mismo id), seller random.
-- Arrancan todos en state 0 (activo); los UPDATE de abajo
-- deciden cuáles pasan a pausado/eliminado/vendido.
INSERT INTO posts (title, description, url, price, vehicle_id, seller_id, create_time, state)
SELECT
    'Post ' || gs,
    'Descripcion del vehiculo ' || gs,
    'post-' || gs,
    (1500 + random() * 60000)::numeric(10,2),
    gs,
    floor(random()*12000)+1,
    NOW() - (random() * interval '730 days'),
    0
FROM generate_series(1, 200000) gs;

-- ~5% pausado y ~5% eliminado, para que el CHECK de state
-- tenga variedad real (no solo 0 y 3).
UPDATE posts SET state = 1
WHERE id IN (SELECT id FROM posts ORDER BY random() LIMIT 10000);

UPDATE posts SET state = 2
WHERE state = 0 AND id IN (
    SELECT id FROM posts WHERE state = 0 ORDER BY random() LIMIT 10000
);

-- ---------- MARCAR VENDIDOS (coherencia con transactions) ----------
-- Los sellers con id 1-3000 NUNCA venden -> esto te da datos
-- reales para la query "sellers con posts activos y cero ventas".
-- Del resto, una porción de sus posts activos pasa a vendido (state 3).
UPDATE posts SET state = 3
WHERE state = 0
  AND seller_id > 3000
  AND id IN (
      SELECT id FROM posts
      WHERE state = 0 AND seller_id > 3000
      ORDER BY random()
      LIMIT 60000
  );

-- ---------- TRANSACTIONS ----------
-- Solo para posts en state = 3. El comprador se elige con sesgo
-- hacia ids bajos (power-law) para que existan "top buyers" reales
-- en vez de una distribución plana. 15% se vende bien por debajo
-- del precio de lista, para que la query de RANK() OVER tenga sentido.
INSERT INTO transactions (post_id, buyer_id, sale_price, sold_at)
SELECT
    p.id,
    (floor(power(random(), 3) * 15000) + 1)::bigint,
    CASE
        WHEN random() < 0.15
            THEN p.price * (0.5 + random()*0.2)   -- vendidos muy por debajo del precio
        ELSE p.price * (0.9 + random()*0.1)        -- resto: cerca del precio de lista
    END,
    p.create_time + (random() * (NOW() - p.create_time))
FROM posts p
WHERE p.state = 3;

-- ---------- IMAGES ----------
-- Entre 1 y 4 fotos por post (segun p.id), la primera siempre es portada.
INSERT INTO images (url, post_id, is_cover)
SELECT
    'https://cdn.curpo.com/' || p.id || '-' || n || '.jpg',
    p.id,
    n = 1
FROM posts p
CROSS JOIN generate_series(1, 1 + (p.id % 4)) n;

COMMIT;

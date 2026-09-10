CREATE TABLE users(
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    mail VARCHAR NOT NULL UNIQUE,
    phone VARCHAR
);

CREATE TABLE vehicles(
    id BIGSERIAL PRIMARY KEY,
    brand VARCHAR NOT NULL,
    model VARCHAR NOT NULL,
    used BOOLEAN NOT NULL,
    km INT NOT NULL CHECK (km >= 0),
    specs JSONB
);

CREATE TABLE posts(
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR NOT NULL,
    description TEXT NOT NULL,
    url VARCHAR NOT NULL UNIQUE,
    price NUMERIC(10, 2) NOT NULL CHECK (price > 0),
    vehicle_id BIGINT NOT NULL REFERENCES vehicles(id),
    seller_id BIGINT NOT NULL REFERENCES users(id),
    create_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    state SMALLINT NOT NULL CHECK (state BETWEEN 0 AND 3) -- 0=activo, 1=pausado, 2=eliminado, 3=vendido
);

CREATE TABLE images(
    id BIGSERIAL PRIMARY KEY,
    url VARCHAR NOT NULL UNIQUE,
    post_id BIGINT NOT NULL REFERENCES posts(id),
    is_cover BOOLEAN NOT NULL
);

CREATE TABLE transactions(
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL REFERENCES posts(id),
    buyer_id BIGINT NOT NULL REFERENCES users(id),
    sale_price NUMERIC(10, 2) NOT NULL,
    sold_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
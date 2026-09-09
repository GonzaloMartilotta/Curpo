CREATE TABLE users(
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    mail VARCHAR NOT NULL UNIQUE,
    phone VARCHAR
);

CREATE TABLE vehicles(
    id SERIAL PRIMARY KEY,
    brand VARCHAR NOT NULL,
    model VARCHAR NOT NULL,
    used BOOLEAN NOT NULL,
    km INT NOT NULL CHECK (km >= 0),
    specs JSONB
);

CREATE TABLE images(
    id SERIAL PRIMARY KEY,
    url VARCHAR NOT NULL UNIQUE,
    vehicle_id int REFERENCES vehicles(id),
    is_cover BOOLEAN NOT NULL
);

CREATE TABLE posts(
    id SERIAL PRIMARY KEY,
    title VARCHAR NOT NULL,
    description TEXT NOT NULL,
    url VARCHAR NOT NULL UNIQUE,
    price INT NOT NULL CHECK (price > 0),
    vehicle_id INT REFERENCES vehicles(id),
    seller_id INT REFERENCES users(id),
    create_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    state SMALLINT NOT NULL CHECK (state BETWEEN 0 AND 3)
);

CREATE TABLE transactions(
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL REFERENCES posts(id),
    buyer_id BIGINT NOT NULL REFERENCES users(id),
    sale_price NUMERIC(10, 2) NOT NULL,
    sold_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
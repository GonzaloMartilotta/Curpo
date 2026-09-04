CREATE TABLE users(
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    mail VARCHAR NOT NULL UNIQUE,
    phone VARCHAR
);

CREATE TABLE vehicles(
    id SERIAL PRIMARY KEY,
    brand VARCHAR NOT NULL,
    model VARCHAR,
    used BOOLEAN NOT NULL,
    km INT NOT NULL CHECK (km >= 0),
    specs JSON
);

CREATE TABLE images(
    id SERIAL PRIMARY KEY,
    url VARCHAR NOT NULL UNIQUE,
    vehicle_id int REFERENCES vehicles(id)
);

CREATE TABLE post(
    id SERIAL PRIMARY KEY,
    url VARCHAR NOT NULL UNIQUE,
    price INT NOT NULL CHECK (price > 0),
    vehicle_id INT REFERENCES vehicles(id),
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    state SMALLINT NOT NULL CHECK (state BETWEEN 0 AND 3),
    seller_id INT REFERENCES users(id)
);
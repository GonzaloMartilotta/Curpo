CREATE TABLE users(
    id SERIAL PRIMARY KEY,
    name TEXT,
    mail TEXT,
    phone INT
);

CREATE TABLE vehicles(
    id SERIAL PRIMARY KEY,
    brand TEXT,
    model TEXT,
    price REAL,
    seller_id INT REFERENCES users(id)
);


package main

import (
	"context"
	"fmt"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
)

func connect() *pgxpool.Pool {
	pool, err := pgxpool.New(context.Background(), os.Getenv("DATABASE_URL")) // Inicia conexion
	if err != nil {
		fmt.Println("Unable to connect to database", err)
		os.Exit(1)
	}

	return pool
}

func main() {
	db := connect()
	defer db.Close()

	var name string
	err := db.QueryRow(context.Background(), "SELECT name FROM users WHERE id=$1", 1).Scan(&name)

	if err != nil {
		fmt.Println("Error on request: ", err)
		os.Exit(1)
	}

	fmt.Println(name)
}

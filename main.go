package main

import (
	"context"
	"fmt"
	"os"

	"github.com/jackc/pgx/v5"
)

func main() {
	conn, err := pgx.Connect(context.Background(), os.Getenv("DATABASE_URL"))

	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to connect to database: %v\n", err)
		os.Exit(1)
	}
	defer conn.Close(context.Background())

	var brand string
	var model string

	rows, err := conn.Query(context.Background(), "SELECT brand, model FROM vehicles")

	for rows.Next() {
		err := rows.Scan(&brand, &model)

		if err != nil {
			fmt.Println(err)
			return
		}

		fmt.Println(brand, model)
	}

	fmt.Println(brand, model)
}

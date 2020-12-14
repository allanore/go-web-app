package main

import (
	"context"
	"database/sql"
	"log"
)

func databaseOpen(server, username, password string) {
	// Connection string for database
	connectionString := "server=server;user id=" + username + ";password=" + password + ";port=1433;database=cloudskillschat;"

	// Open database connection
	dbOpen, err := sql.Open("mssql", connectionString)
	if err != nil {
		log.Fatal("Connection to the SQL Database was unsuccessful")
	}

	ctx := context.Background()
	dbOpen.PingContext(ctx)

	// Close the database once it's done being used. Although databases can technically
	// stay open, it'll just cause the use of resources for no reason.
	defer dbOpen.Close()
}

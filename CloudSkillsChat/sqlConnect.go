package main

import (
	"context"
	"database/sql"
	"log"
)

func databaseOpen(server, username, password string) {
	// Connection string for database
	connectionString := "Server=tcp:" + server + ",1433;Initial Catalog=cloudskillschat;Persist Security Info=False;User ID=" + username + ";Password=" + password + ";MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

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

package main

import (
	"context"
	"database/sql"
	"log"
)

func main() {
	databaseOpen(
		"tcp:cloudskillschat.database.windows.net",
		"mike",
		"W3lcomeWorld12!@",
	)
}

func databaseOpen(server, username, password string) {
	// Connection string for database
	connectionString := "server=server;user id=" + username + ";password=" + password + ";port=1433;database=cloudskillschat;"

	// Open database connection
	dbOpen, err := sql.Open("mssql", connectionString)
	if err != nil {
		log.Fatal("Connection to the SQL Database was unsuccessful")
	} else {
		ctx := context.Background()
		dbOpen.PingContext(ctx)
	}
}

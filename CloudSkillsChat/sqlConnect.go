package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
)

var db *sql.DB
var server = "cloudskillschat.database.windows.net"
var port = 1433
var user = "mike"
var password = "W3lcomeWorld12!@"
var database = "cloudskillschat"

func databaseOpen() string {
	// Connection string for database
	connectionString := fmt.Sprintf("server=%s;user id=%s;password=%s;port=%d;database=%s;",
		server, user, password, port, database)

	// Open database connection
	dbOpen, err := sql.Open("sqlserver", connectionString)
	if err != nil {
		log.Fatal("Connection to the SQL Database was unsuccessful")
	}

	ctx := context.Background()
	dbOpen.PingContext(ctx)

	// Close the database once it's done being used. Although databases can technically
	// stay open, it'll just cause the use of resources for no reason.
	defer dbOpen.Close()

	return ""
}

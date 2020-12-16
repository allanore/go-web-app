package main

import (
	"encoding/json"
	"net/http"
	"html/template"
	"fmt"
	_ "github.com/lib/pq"
	"database/sql"
)

var db *sql.DB
var tpl *template.Template

func init() {
	var err error
	db, err = sql.Open("postgres", "postgres://msgsvc:password@localhost/messages?sslmode=disable")
	if err != nil {
		panic(err)
	}

	if err = db.Ping(); err != nil {
		panic(err)
	}
	fmt.Println("You connected to your database.")

	tpl = template.Must(template.ParseGlob("templates/*.html"))
}

type Comment struct {
	ID int
	Name   string
	Message  string
}
func main() {
	http.HandleFunc("/", index)
	http.Handle("/css/", http.StripPrefix("/css", http.FileServer(http.Dir("./css"))))
	http.HandleFunc("/message", messageCreateProcess)
	http.HandleFunc("/update", updateChat)
	http.HandleFunc("/chat", chatPage)
	http.ListenAndServe(":8080", nil)
}

func index(res http.ResponseWriter, req *http.Request) {

	if req.Method != "GET" {
		http.Error(res, http.StatusText(405), http.StatusMethodNotAllowed)
		return
	}


	tpl.ExecuteTemplate(res, "index.html", nil)

}

func chatPage(res http.ResponseWriter, req *http.Request) {

	if req.Method != "GET" {
		http.Error(res, http.StatusText(405), http.StatusMethodNotAllowed)
		return
	}


	tpl.ExecuteTemplate(res, "chat.html", nil)

}


func messageCreateProcess(res http.ResponseWriter, req *http.Request) {
	if req.Method != "POST" {
		http.Error(res, http.StatusText(405), http.StatusMethodNotAllowed)
		return
	}

	// get form values
	cmt := Comment{}
	cmt.Name = req.FormValue("name")
	cmt.Message = req.FormValue("message")

	// validate form values
	if cmt.Name == "" || cmt.Message == "" {
		http.Error(res, http.StatusText(400), http.StatusBadRequest)
		return
	}

	// insert values
	var err error
	_, err = db.Exec("INSERT INTO queue (name, message) VALUES ($1, $2);", cmt.Name, cmt.Message)
	if err != nil {
		http.Error(res, http.StatusText(500), http.StatusInternalServerError)
		return
	}

	// Redirect
	http.Redirect(res, req, "/chat", http.StatusSeeOther)
}

func updateChat(res http.ResponseWriter, req *http.Request) {

	if req.Method != "GET" {
		http.Error(res, http.StatusText(405), http.StatusMethodNotAllowed)
		return
	}

	rows, err := db.Query("SELECT * FROM queue;")
	if err != nil {
		http.Error(res, http.StatusText(500), 500)
		return
	}
	defer rows.Close()

	queue := make([]Comment, 0)
	for rows.Next() {
		msg := Comment{}
		err := rows.Scan(&msg.ID, &msg.Name, &msg.Message) // order matters
		if err != nil {
		http.Error(res, http.StatusText(500), 500)
			return
		}
		queue = append(queue, msg)
	}
	
	if err = rows.Err(); err != nil {
		http.Error(res, http.StatusText(500), 500)
		return
	}
	
	bs, err := json.Marshal(queue)
	if err != nil {
		fmt.Println("error: ", err)
	}
	
	fmt.Fprint(res, string(bs))

}


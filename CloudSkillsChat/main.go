package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
)

var tpl *template.Template

var server string = "tcp:cloudskillschat.database.windows.net"
var username string = "mike"
var password string = "W3lcomeWorld12!@"

func init() {
	tpl = template.Must(template.ParseFiles("index.html"))
}

func main() {
	db := databaseOpen(server, username, password)
	fmt.Println(db)

	http.HandleFunc("/", index)
	http.Handle("/css/", http.StripPrefix("/css", http.FileServer(http.Dir("./css"))))
	http.ListenAndServe(":8080", nil)
}

func index(res http.ResponseWriter, req *http.Request) {

	err := req.ParseForm()
	if err != nil {
		log.Println(err)
	}
	fmt.Println(req.Form)
	fmt.Printf("%T\n", req.Form)

	data := struct {
		Method      string
		URL         string
		Submissions map[string][]string
	}{
		req.Method,
		req.URL.Path,
		req.Form,
	}
	tpl.ExecuteTemplate(res, "index.html", data)
}

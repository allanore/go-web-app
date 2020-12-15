package main

import (
	"net/http"
	"html/template"
	"fmt"

)

var tpl *template.Template

func init() {

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

	// INSERT SQL PORTION TO CREATE NEW TABLE RECORDS




	// Redirect
	http.Redirect(res, req, "/chat", http.StatusSeeOther)
}

func updateChat(res http.ResponseWriter, req *http.Request) {

	if req.Method != "GET" {
		http.Error(res, http.StatusText(405), http.StatusMethodNotAllowed)
		return
	}

	// INSERT SQL QUERY TO GET THE ENTIRE CHAT LOG AND OUTPUT IT TO JSON
	

	//Pass JSON Chat log to page
	bs := "Should be Chat log"
	fmt.Fprint(res, string(bs))

}


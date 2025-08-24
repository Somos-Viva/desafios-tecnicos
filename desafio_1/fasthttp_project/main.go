package main

import (
	"log"

	"github.com/valyala/fasthttp"
)

func helloWorldHandler(ctx *fasthttp.RequestCtx) {
	if !ctx.IsGet() {
		ctx.Error("Method not allowed", fasthttp.StatusMethodNotAllowed)
		return
	}

	if string(ctx.Path()) != "/" {
		ctx.Error("Not found", fasthttp.StatusNotFound)
		return
	}

	ctx.SetContentType("text/plain")
	ctx.WriteString("Hello, World")
}

func main() {
	server := &fasthttp.Server{
		Handler: helloWorldHandler,
	}

	log.Println("Server starting on http://localhost:8080")
	log.Fatal(server.ListenAndServe(":8080"))
}

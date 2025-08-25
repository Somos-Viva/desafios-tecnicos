package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"

	"github.com/valyala/fasthttp"
)

func handleRequest(ctx *fasthttp.RequestCtx) {
	path := string(ctx.Path())
	if path == "/" {
		ctx.SetContentType("text/plain")
		fmt.Fprintf(ctx, "Hello, World")
	} else {
		ctx.Error("Not Found", fasthttp.StatusNotFound)
	}
}

func main() {
	fmt.Println("Iniciando servidor FastHTTP na porta 5002...")

	// Configurar graceful shutdown
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)

	// Iniciar servidor em uma goroutine
	go func() {
		if err := fasthttp.ListenAndServe("localhost:5002", handleRequest); err != nil {
			log.Fatalf("Erro ao iniciar o servidor: %s", err)
		}
	}()

	fmt.Println("Servidor rodando em http://localhost:5002")
	fmt.Println("Pressione Ctrl+C para encerrar")

	// Esperar sinal de interrupção
	<-c
	fmt.Println("\nEncerrando servidor...")
}

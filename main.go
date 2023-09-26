package main

import (
	"fmt"
	"net/http"
	"time"
)

func fibonacci(n int) uint64 {
	if n <= 0 {
		return 0
	} else if n == 1 {
		return 1
	}

	a, b := uint64(0), uint64(1)
	for i := 2; i <= n; i++ {
		a, b = b, a+b
	}

	return b
}

func fibonacciHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Print("Received request...\n")
	startTime := time.Now()
	result := fibonacci(100000000)
	elapsedTime := time.Since(startTime)

	fmt.Fprintf(w, "Fibonacci(100000000) = %d\n", result)
	fmt.Fprintf(w, "Time taken: %s\n", elapsedTime)
}

func healthz(w http.ResponseWriter, r *http.Request) {}

func main() {
	http.HandleFunc("/healthz", healthz)
	http.HandleFunc("/fibonacci", fibonacciHandler)
	fmt.Println("Server is listening on port 8000...")
	http.ListenAndServe(":8000", nil)
}

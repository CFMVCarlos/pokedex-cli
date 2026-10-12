.PHONY: all build run test lint clean

all: build

build:
	go build -o pokedexcli .

run: build
	./pokedexcli

test:
	go test -v ./...

lint:
	go vet ./...

clean:
	rm -f pokedexcli

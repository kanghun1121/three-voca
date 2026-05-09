.PHONY: gen build test graph clean

gen:
	tuist generate --no-open

build:
	tuist build

test:
	tuist test

graph:
	tuist graph --no-open

clean:
	tuist clean

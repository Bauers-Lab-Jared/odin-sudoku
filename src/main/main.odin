package main

import "core:fmt"
import "core:testing"

main :: proc() {
	fmt.println("sup")
}

@(test)
tests :: proc(_: ^testing.T) {
	assert(true, "we did it")
	assert(false, "bad things")
}

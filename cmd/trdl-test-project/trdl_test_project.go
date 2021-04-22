package main

import (
	"fmt"

	"github.com/werf/trdl-test-project/pkg/common"

	"github.com/DyegoCosta/snake-game/snake"
)

func main() {
	fmt.Printf("Hi there! This is trdl-test-project cli tool.\n")
	fmt.Printf("Version: %s\n", common.Version)

	snake.NewGame().Start()
}

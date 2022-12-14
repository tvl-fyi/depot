package main

import (
	"errors"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"utils"
)

func main() {
	audit := flag.Bool("audit", false, "Output all symlinks that would be deleted. This is the default behavior. This option is mutually exclusive with the --seriously option.")
	seriously := flag.Bool("seriously", false, "Actually delete the symlinks. This option is mutually exclusive with the --audit option.")
	repoName := flag.String("repo-name", "briefcase", "The name of the repository.")
	flag.Parse()

	if !*audit && !*seriously {
		log.Fatal(errors.New("Either -audit or -seriously needs to be set."))
	}
	if *audit == *seriously {
		log.Fatal(errors.New("Arguments -audit and -seriously are mutually exclusive"))
	}

	home, err := os.UserHomeDir()
	utils.FailOn(err)
	count := 0

	err = filepath.Walk(home, func(path string, info os.FileInfo, err error) error {
		if utils.IsSymlink(info.Mode()) {
			dest, err := os.Readlink(path)
			utils.FailOn(err)

			predicate := func(dest string) bool {
				return strings.Contains(dest, *repoName)
			}

			if predicate(dest) {
				if *audit {
					fmt.Printf("%s -> %s\n", path, dest)
				} else if *seriously {
					fmt.Printf("rm %s\n", path)
					err = os.Remove(path)
					utils.FailOn(err)
				}
				count += 1
			}
		}
		return nil
	})
	utils.FailOn(err)
	if *audit {
		fmt.Printf("Would have deleted %d symlinks.\n", count)
	} else if *seriously {
		fmt.Printf("Successfully deleted %d symlinks.\n", count)
	}

	os.Exit(0)
}

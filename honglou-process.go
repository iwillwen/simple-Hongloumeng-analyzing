package main

import (
	"bufio"
	"container/list"
	"fmt"
	"os"
	"regexp"
	"strings"
)

func main() {
	// Reading the segment results from R
	file, err := os.Open("./honglou-words.txt")
	check(err)
	scanner := bufio.NewScanner(file)
	chaps := list.New()

	// Slicing the words
	currChap := []string{}
	for scanner.Scan() {
		isMeta, err := regexp.Match("^#", []byte(scanner.Text()))
		check(err)

		if !isMeta {
			words := strings.Split(scanner.Text(), ",")
			currChap = append(currChap, words...)
		}

		if isMeta && len(currChap) != 0 {
			chaps.PushBack(currChap)
			currChap = []string{}
		}
	}

	// Counting the words frequency
	wordsFrequenciesInChaps := list.New()
	var i = 1
	for e := chaps.Front(); e != nil; e = e.Next() {
		words := e.Value.([]string)
		uniqueWords := unique(words)

		frequencies := make(map[string]int)
		for _, word := range uniqueWords {
			frequencies[word] = 0
		}

		for _, word := range words {
			_, match := frequencies[word]

			if match {
				frequencies[word] += 1
			}
		}

		wordsFrequenciesInChaps.PushBack(frequencies)
		fmt.Println(i)
		i++
	}

	// Output the result
	outputFile, err := os.Create("./honglou-words-frequencies.txt")
	check(err)
	for chap := wordsFrequenciesInChaps.Front(); chap != nil; chap = chap.Next() {
		for key, value := range chap.Value.(map[string]int) {
			line := fmt.Sprintf("%s %d\n", key, value)
			_, err := outputFile.WriteString(line)
			check(err)
		}

		_, err := outputFile.WriteString("---\n")
		check(err)

		outputFile.Sync()
	}
}

// Functions
func check(e error) {
	if e != nil {
		panic(e)
	}
}
func unique(e []string) []string {
	r := []string{}

	for _, s := range e {
		if !contains(r[:], s) {
			r = append(r, s)
		}
	}
	return r
}

func contains(e []string, c string) bool {
	for _, s := range e {
		if s == c {
			return true
		}
	}
	return false
}

func Filter(s []string, fn func(string) bool) []string {
	var p []string // == nil
	for _, v := range s {
		if fn(v) {
			p = append(p, v)
		}
	}
	return p
}

package main

import (
	"encoding/json"
	"errors"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"
	"text/template"

	"github.com/urfave/cli"
)

var TemplateFiles = []string{"schemas.tpl", "models.tpl", "resolvers.tpl"}
var OutputExtensions = []string{"gql", "js", "js"}

type Model struct {
	Name      string
	LowerName string
	Spec      map[string]interface{}
}

// ReadTemplate reads the contents of template file
func ReadTemplate(fileName string) string {
	content, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic(err)
	}
	return string(content)
}

func ReadSpec(fileName string) (decoded map[string]interface{}) {
	content, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic(err)
	}

	if err := json.Unmarshal(content, &decoded); err != nil {
		panic(err)
	}

	return decoded
}

func ExecuteTemplate(u *Model, templateText, outputFile string, file *os.File) error {
	compiledTemplate, err := template.New(u.Name).Parse(templateText)

	if err != nil {
		return err
	}

	if file != nil {
		return compiledTemplate.Execute(file, u)
	}

	fileHandler, err := os.Create(outputFile)
	if err != nil {
		return err
	}
	// Excecute template
	return compiledTemplate.Execute(fileHandler, u)
}

func main() {
	app := cli.NewApp()
	app.Name = "factory"
	app.Usage = "Model factory or GraphQL Servers"
	app.Version = "0.1.0"

	// Value holders
	// var modelName, configFile string
	var modelName, lowerName, templateDir, specFile string

	// Configure CLI flags
	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:        "name",
			Value:       "",
			Usage:       "Name of the new model to be created",
			Destination: &modelName,
		},
		cli.StringFlag{
			Name:        "lower",
			Value:       "",
			Usage:       "Lower name of the new model to be created",
			Destination: &lowerName,
		},
		cli.StringFlag{
			Name:        "templates",
			Value:       "tpl",
			Usage:       "name of template dir",
			Destination: &templateDir,
		},
		cli.StringFlag{
			Name:        "spec",
			Value:       "",
			Usage:       "name of spec file",
			Destination: &specFile,
		},
	}

	// Default main action
	app.Action = func(c *cli.Context) error {

		if modelName == "" {
			return errors.New("Model name required")
		}

		if lowerName == "" {
			lowerName = strings.ToLower(modelName)
		}

		var u Model

		// Read spec and generate model
		if specFile != "" {
			modelSpec := ReadSpec(specFile)

			u = Model{
				Name:      modelName,
				LowerName: lowerName,
				Spec:      modelSpec,
			}

		} else {
			u = Model{
				Name:      modelName,
				LowerName: lowerName,
			}
		}

		// Read template files

		for i := range TemplateFiles {
			tpl := TemplateFiles[i]
			name := strings.Split(tpl, ".")[0]
			templateFile := filepath.Join(templateDir, tpl)
			outputFile := filepath.Join("src", name, u.LowerName+"."+OutputExtensions[i])
			templateText := ReadTemplate(templateFile)

			err := ExecuteTemplate(&u, templateText, outputFile, nil)
			if err != nil {
				panic(err)
			}
		}

		// Return the app's action
		return nil
	} // end of main action

	err := app.Run(os.Args)
	if err != nil {
		log.Fatal(err)
	}
}

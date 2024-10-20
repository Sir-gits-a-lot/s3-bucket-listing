package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"log"
	"net/http"
	"strings"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/gorilla/mux"
)

var s3Client *s3.Client
var bucketName string

type BucketContentResponse struct {
	Content []string `json:"content"`
}

func listBucketContent(w http.ResponseWriter, r *http.Request) {

	if r.Method != "GET" {
		http.Error(w, "Method Not Supported", http.StatusNotFound)
		return
	}

	// fmt.Fprintf(w, "Entered list bucket content function")
	
	vars := mux.Vars(r)
	path := vars["path"]

	// path ends with a slash
	if path != "" && !strings.HasSuffix(path, "/") {
		path += "/"
	}

	// Create a ListObjectsV2 request
	resp, err := s3Client.ListObjectsV2(context.TODO(), &s3.ListObjectsV2Input{
		Bucket:    aws.String(bucketName),
		Prefix:    aws.String(path),
		Delimiter: aws.String("/"),
	})

	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to list bucket contents: %v", err), http.StatusInternalServerError)
		return
	}

	content := []string{}

	// Add directories
	for _, prefix := range resp.CommonPrefixes {
		parts := strings.Split(*prefix.Prefix, "/")
		dir := parts[len(parts)-2]
		content = append(content, dir)
	}

	// Add files (Contents)
	for _, object := range resp.Contents {
		key := *object.Key
		if key != path { 
			parts := strings.Split(key, "/")
			file := parts[len(parts)-1]
			content = append(content, file)
		}
	}

	// Check if path exists but is empty (for the additional test cases)
	if len(content) == 0 {
		if path != "/" {
			existsResp, err := s3Client.ListObjectsV2(context.TODO(), &s3.ListObjectsV2Input{
				Bucket: aws.String(bucketName),
				Prefix: aws.String(path),
			})

			if err != nil || len(existsResp.Contents) == 0 {
				http.Error(w, "Path not found", http.StatusNotFound)
				return
			}
		}
	}

	// Return JSON response
	response := BucketContentResponse{Content: content}
	w.Header().Set("Content-Type", "application/json")

	// Marshalling for identation
	jsonResponse, err := json.Marshal(response)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to marshal JSON: %v", err), http.StatusInternalServerError)
		return
	}

	// Convert the JSON into a string and replace `": [` with `": [ ` for the desired space after "content:"
	formattedResponse := strings.Replace(string(jsonResponse), `":[`, `": [ `, 1) + "\n"

	// Write the final response
	w.Write([]byte(formattedResponse))

	//json.NewEncoder(w).Encode(response)
}


func main(){

	// Define a default bucket name
	defaultBucketName := "unique-s3-bucket-123"

	// Check if bucket name is provided as a command-line argument
	if len(os.Args) > 1 {
		bucketName = os.Args[1] // Get the bucket name from the first command-line argument
	} else {
		bucketName = defaultBucketName // Use default bucket name
		fmt.Printf("No bucket name provided. Using default: %s\n", defaultBucketName)
	}

	cfg, err := config.LoadDefaultConfig(context.TODO()) // Change region if needed
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}

	s3Client = s3.NewFromConfig(cfg)


	r := mux.NewRouter()

	r.HandleFunc("/list-bucket-content", listBucketContent).Methods("GET")
	r.HandleFunc("/list-bucket-content/{path:.*}", listBucketContent).Methods("GET")

	fmt.Printf("Starting Server at port 5000\n")

	log.Fatal(http.ListenAndServe(":5000", r)) 

	// log.Fatal(http.ListenAndServeTLS(":5000","ssl/server.crt", "ssl/server.key", r)) 

}
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"hello-world/digimodel"
	"log"
	"strings"
)

// Lambda handler function
func handler(ctx context.Context, kinesisEvent events.KinesisEvent) (map[string]interface{}, error) {
	var kinesisBatchResponse map[string]interface{}
	var batchItemFailures []map[string]interface{}

	// no records to process, so just break out early
	if len(kinesisEvent.Records) == 0 {
		return kinesisBatchResponse, nil
	}

	for _, record := range kinesisEvent.Records {
		curRecordSequenceNumber := ""

		// Begin processing events
		//if event.EventObject == digimodel.EventObject_Case && event.EventType == digimodel.EventType_CaseStatusChanged
		err := processRecord(record)
		if err != nil {
			log.Printf("Failed to process record: %v", err)
			curRecordSequenceNumber = record.Kinesis.SequenceNumber
			batchItemFailures = append(batchItemFailures, map[string]interface{}{"itemIdentifier": curRecordSequenceNumber})
		}

		// Add a condition to check if the record processing failed
		//if curRecordSequenceNumber != "" {
		//	batchItemFailures = append(batchItemFailures, map[string]interface{}{"itemIdentifier": curRecordSequenceNumber})
		//}
	}

	kinesisBatchResponse = map[string]interface{}{
		"batchItemFailures": batchItemFailures,
	}
	return kinesisBatchResponse, nil
}

func main() {
	// Start Lambda
	lambda.Start(handler)
}

func processRecord(record events.KinesisEventRecord) error {
	// Implement your record processing logic here
	// Locate ClusterServerInfo
	// Make Record to transform into a DigiCaseStatusUpdate record
	// GetOrCreateClusterPersisterForTarget
	// UpdatePersisterTargetStatus to store most recent error
	// InsertRecords to SendCaseStatusChangedEvent to VC via GRPC

	var event digimodel.StreamEventRequest

	// Log the raw data for debugging
	fmt.Printf("Raw data: %s\n", string(record.Kinesis.Data))

	// Unmarshal the Data string into a digimodel.StreamEventRequest
	err := json.Unmarshal(record.Kinesis.Data, &event)
	if err != nil {
		log.Printf("failed to process event due to invalid kinesis record with error: %v", err)
		// If event cannot be unmarshalled, there is a formatting issue with the event so do not retry
		return err
	}

	log.Printf("Unmarshalled event data %+v", event.Data)

	log.Printf("processing event data: %v\n", record.Kinesis.Data)

	//if strings.TrimSpace(strings.ToLower(event.Data.Case.Status)) == "closed" {
	if strings.TrimSpace(strings.ToLower(string(event.Data.Brand.TenantID))) == "0" {
		err = fmt.Errorf("failed to process event data")
		log.Println(err)
		return err
	}
	return nil
}

# Submission

## Definition

A Submission is one immutable raw intake-form response or imported referral.
Several Submissions may belong to the same Application. A Submission can be a
duplicate, a correction, a follow-up, or the source of additional RepairNeeds.

The raw response is never edited. Corrections arrive as another Submission or
as normalized Application data with an auditable event.

## State

```ts
type SubmissionState =
  | "received"
  | "processing"
  | "matched"
  | "needsReview"
  | "invalid"
  | "withdrawn";
```

The projected state should include:

- Raw payload reference
- Source and received timestamp
- Processing status
- Resolved PlaceCode
- Matched Application ID
- Duplicate/repeat determination
- Extracted repair-request IDs
- Processing errors

## Commands

- `receiveSubmission`
- `retrySubmissionProcessing`
- `matchSubmissionToApplication`
- `confirmSubmissionMatch`
- `rejectSubmissionMatch`
- `withdrawSubmission`

## Processes

- `ingestSubmission`
- `normalizeSubmissionData`
- `resolvePlaceCode`
- `checkForDuplicateApplication`
- `extractRepairRequests`
- `matchRepairRequestsToExistingNeeds`
- `attachSubmissionToApplication`

## Events

- `submission.received`
- `submission.normalized`
- `submission.placeCodeResolved`
- `submission.applicationMatchFound`
- `submission.applicationMatchNotFound`
- `submission.matchReviewRequired`
- `submission.linkedToApplication`
- `submission.repairRequestsExtracted`
- `submission.processingFailed`
- `submission.withdrawn`

## Reducer

`submissionReducer` handles the following transitions:

| Event | Projected change |
|---|---|
| `submission.received` | Set `status = "received"` and record `receivedAt`. |
| `submission.normalized` | Set `status = "processing"` and store normalized values separately from the raw payload. |
| `submission.placeCodeResolved` | Store the PlaceCode and match inputs. |
| `submission.applicationMatchFound` | Store the proposed Application ID. |
| `submission.applicationMatchNotFound` | Mark the Submission as requiring a new Application. |
| `submission.matchReviewRequired` | Set `status = "needsReview"`. |
| `submission.linkedToApplication` | Set `status = "matched"` and store `applicationId`. |
| `submission.repairRequestsExtracted` | Store extracted request IDs. |
| `submission.processingFailed` | Set `status = "invalid"` and store errors. |
| `submission.withdrawn` | Set `status = "withdrawn"`. |

## Tasks

- `REVIEW_NEW_SUBMISSION` - Review New Submission
- `RESOLVE_SUBMISSION_PLACECODE` - Resolve Submission PlaceCode
- `REVIEW_POSSIBLE_DUPLICATE` - Review Possible Duplicate
- `CONFIRM_APPLICATION_MATCH` - Confirm Existing Application Match
- `CORRECT_UNPROCESSABLE_SUBMISSION` - Correct Unprocessable Submission
- `REVIEW_EXTRACTED_REPAIR_REQUESTS` - Review Extracted Repair Requests

## Completion rules

| Task | Completion evidence |
|---|---|
| Review New Submission | `submission.normalized` |
| Resolve Submission PlaceCode | `submission.placeCodeResolved` |
| Review Possible Duplicate | `submission.linkedToApplication` after human confirmation, or an explicit no-match decision |
| Confirm Existing Application Match | `submission.linkedToApplication` with an existing Application ID |
| Correct Unprocessable Submission | A later successful `submission.normalized` event |
| Review Extracted Repair Requests | All extracted requests have a reviewed disposition |


┌─────────────────────────────────────────────────────────────────────────────────┐
│                          USER EXPERIENCE FLOW                                   
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  
│  1. Softr Page: User sees case list with available actions                      
│  2. User clicks: "+ Add Event"                                                  
│  3. Modal Opens: Task type dropdown (filtered by display conditions)            
│  4. User Selects: Task type → Form dynamically updates                         
│  5. User Fills: Relevant fields (dates, notes, uploads)                         
│  6. User Submits: Form validates, sends to API                                 
│  7. System Processes:                                                           
│     • Updates Progress Ledger (immutable)                                      
│     • Generates documents (if applicable)                                      
│     • Stores documents in Bucket (naming convention applied)                   
│     • Updates case status (display conditions)                                 
│     • Triggers notifications (if applicable)                                  
│  8. User Sees: Success confirmation + updated task list                       
│                                                                                  
└─────────────────────────────────────────────────────────────────────────────────┘
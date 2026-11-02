## The "State Mutator" Concept

This is the key insight you need to develop. The State Mutator is what makes the system work.

### What Is State?

**State is the current condition of an Application/Case/Project.**

Example: 
Application: 42-CHERRY                     
 status: "active"                                                      
phase: 2 (Processing)                                                 
milestones_completed: ["submitted", "claimed", "assessor_assigned"]  
has_income_verification: false                                       
has_ownership_verification: false                                   
assessment_completed: false                                        
tasks: [                                                          
 {id: 1, description: "Verify income", status: "pending"},         
 {id: 2, description: "Schedule assessment", status: "in_progress"}  

### What Is a State Mutator?

A State Mutator is a function that **changes state** based on events.

Example:

Event: document_uploaded (type: "income_verification")                 
MUTATOR:                                                            
1. Set has_income_verification = true                            
2. Check: Does this complete a milestone?                         
3. If yes → mark milestone as complete                              
4. Check: Are all prerequisites met for next phase?                
5. If yes → advance phase
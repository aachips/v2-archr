
1. Activity Log Entry                          
timestamp: 2026-09-01 10:00:00                            
user_id: usr_abcdefg                                                
action: assessment_completed                                       
application_id: app_42CHERRY                                        

2. System Checks                                                              
"Does 'assessment_completed' complete a milestone?"   
Yes → M6: Assessment Completed                                     

  3. Milestone Updated
Milestone: M6                                                        
completed: true                                                     
completed_at: 2026-09-01 10:00:00                          
 completed_by: usr_abcdefg                                      


## Mapping to Submission/Application/Case/Project

The Activity Log needs to work with the new naming system:


 ACTIVITY LOG ENTITIES                           

SUBMISSION LEVEL                         
 • submission_created      
 • submission_updated                
 • submission_deduplicated                           

APPLICATION LEVEL           
• application_created                              
• application_status_changed                                       
• application_claimed                                               
• document_uploaded                                                
• eligibility_report_generated                                          

 CASE LEVEL                                   
• case_created                                        
• case_assigned                                       
• case_status_changed                                             
• case_claim_expired                                      


PROJECT LEVEL                                                     
• project_created                                                      
• project_budget_approved                                          
• project_task_completed                                              
• project_completed        

``` 
-- Joel is applying for a grant, needs to pull all records of home repairs in Woodfin / 28804 ZIP Code
-- Unspoken criteria: Case matches eligibility requirements, the client isn't unreachable, the repair needs are ~25,000 dollars, and the family has not already been helped.

select * from anchor_records 
where zip == '28804' OR town == ('Woodfin' || 'Asheville')
	   eligibility.habitat == 'true', 
	   contact_status != 'failed', 
	   project_completion_date == ('empty' | NULL)
```

unspoken criteria that: 
+ match eligibility requirements for ARCHR,
+ haven't been proven to be unreachable
+ have repair needs around ~25,000 dollars
	+ two ways to get estimate number [imaginary numbers vs estimated vs real approximates], [estimated, allocated, spent] all handled same way $###
+ haven't already helped

dependencies: 
+ mapping/GIS check
+ Eligibility check
+ contact logging happens
+ date of completion recording
+ unclaimed by other organization
---
document_name: Frontend vs Backend — What's Really Broken
document_type: Explanatory Guide
version: 1.0
last_updated: 2026-08-06
author: ARCHR Development Team
audience: All Platform Users, Non-Technical Readers
complexity_level: Beginner
estimated_reading_minutes: 6
tags: [frontend, backend, airtable, explanation]
---

You might hear the terms Front End and Back End, and may not know the distinction between the two fully. This is a primer and framework for explaining what is wrong. 

Many of the issues raised with the current platform were directed at Airtable, but those issues were issues with the front-end. 

Airtable is our database. Databases are organized for efficiency, to be read by machines, and for retrieval processes.

If you go to a store, and you have to, as a customer, go to the stock room in the back to find what you are looking for.that's not a problem with the stock room. That's a problem with the store layout. The stock room is organized for efficiency, not for shopping. Customers shouldn't be in the back room.

The Stock Room is the Database in this metaphor. A stock room is organized for staff, while a database is organized for machines. Those staff are often trained in how to navigate the stock room so it is not confusing or time consuming to do tasks. Customers don't go to the stock room. Databases store information. They have confusing coded labels. If you are not trained to interpret that information, it will be incredibly confusing.

The failure on part of the Airtable, or our database, is that we haven't offered a training in how to use it. But if we had a working front-end to retrieve and display that information as we need it, than nobody would have to go on Airtable to find what they need to do their jobs. 

Everyone is shopping in the back room.

### Survivorship Bias and WWII Fighter Planes

"We are in the year 1943 and American Bombers are suffering lots of losses by the German counter-air defense. The military needed to minimize the losses and they ask for the help of the SRG at Columbia University, where works a Jewish Austrian-Hungarian refugee.

His name is Abraham Wald and the task of finding a solution on the armoring of the planes is his duty. He is given a lot of data on the aircraft damage, including the location of the damage suffered by the planes that were hit by the Nazis.

Press enter or click to view image in full size

![](https://miro.medium.com/v2/resize:fit:700/1*FD_DTgmZQpscjhzmNWmJ2Q.png)

Location of the hits in the aircraft. [McGeddon](https://commons.wikimedia.org/wiki/File:Survivorship-bias.png), [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/), via Wikimedia Commons

The military expected Wald to give them some suggestions on how to reinforce the spots of the planes that received the most hits by the German defenses.

“Wait,” said Wald, “What you should do is reinforce the area around the motors and the cockpit. You should remember that the worst-hit planes never come back. All the data we have come from planes that make it to the bases. You don’t see that the spots with no damage are the worst places to be hit because these planes never come back.”

This intuition is absolutely true, and it is called survivorship bias. The planes that were hit in the area of the motor, of the ones that lost their pilots never came back and were not part of the data. This is why the military had to concentrate on reinforcing exactly those areas.""


https://www.cantorsparadise.com/survivorship-bias-and-the-mathematician-who-helped-win-wwii-356b174defa6

Engineers looked at damaged planes from war. They saw where all the artillery holes were and thought, "these are the weak spots." But the planes that didn't return were hit elsewhere. The real weak spots were misidentified and not visible to the conventional analysis. 

Users look at confusing database fields, they think that the database is the problem. the confusing fields are supposed to be confusing. The real issue is and has been for some time the front end, which isn't a visible target for scrutiny because it doesn't exist.

The database is not the problem. The lack of a proper interface is.


## Why This Matters

### What Users Think Is Wrong

> _"The database is confusing."_  
> _"There are too many coded fields."_  
> _"I can't find what I need."_

### What Is Actually Wrong

> _"There is no front-end interface that translates database fields into meaningful labels."_  
> _"Users are being asked to navigate the database directly."_  
> _"Softr is not providing enough abstraction."_

---

## The Softr Problem

Softr is a front-end builder, but it's limited. It's great for simple views, but it doesn't provide the kind of abstraction that a proper application would.

|What Softr Can Do|What It Can't Do|
|---|---|
|Display records|Create complex workflows|
|Simple filters|Abstract database complexity|
|Basic forms|Guide users through processes|
|Read data|Hide database structure|

**Users are seeing the database layer because Softr isn't abstracting it away.**

---

## The Front-End Layer You're Building

The app prototype you're building addresses exactly this:

|Database Layer (Airtable)|Front-End Layer (Your App)|
|---|---|
|"case_id"|"Case Number"|
|"app_first_name"|"First Name"|
|"app_last_name"|"Last Name"|
|"funding_approved"|"Approved Funding"|
|"funding_remaining"|"Remaining Budget"|
|The user sees codes|The user sees labels|
|The user navigates tables|The user navigates workflows|
|The user needs training|The user learns intuitively|

**Your app is building the store so people don't have to shop in the back room.**

---

## How To Explain This To Frustrated People

### The Short Version

> _"A lot of what's confusing about the current system isn't Airtable's fault. It's the front-end's fault. You're being asked to navigate a database directly, instead of through a guided interface. That's like making you shop in the stock room instead of the store."_

### The Analogy Version

> _"Imagine going to a grocery store where they don't have aisles or signs. You have to go into the back room and look through boxes labeled 'SKU-4892-B' to find your groceries. That's not a problem with the boxes—it's a problem with the store design._
> 
> _The database is the back room. It's organized for efficiency, not for shopping. The front-end is the store. Right now, we've been asking everyone to shop in the back room, and that's where the frustration comes from."_

### The Technical Version

> _"Airtable is the data layer. Softr is the front-end layer. Softr isn't abstracting the database structure well enough, so users are seeing fields like 'app_first_name' instead of 'First Name.' The app we're building adds a proper front-end layer so users interact with labels and workflows, not tables and codes."_

---

## The Kicker: "I Don't Know How to Explain This to People in Pain"

You're right—frustrated people aren't looking for a systems architecture lesson. They're looking for relief. So don't explain it. **Show it.**

### The Demonstration

> _"Here's what I'm building. See how it says 'Case Number' instead of 'case_id'? See how you can click 'View Funding' and see the approved amount, spent amount, and remaining balance in one place? That's what we're moving toward. The database is still the database—but you won't see it. You'll see a system designed for you."_

### The Promise

> _"When we're done, you won't interact with Airtable directly. You'll interact with a front-end designed for your role, and the front-end will talk to the database behind the scenes. We're building the store so you don't have to go into the back room."_

---
---

## The Baked Thought, Assessed

|Your Thought|Assessment|
|---|---|
|"Many issues aren't with Airtable—they're with Softr"|✅ Correct|
|"Users shouldn't interact directly with the database"|✅ Correct|
|"The database is organized for efficiency, not for end users"|✅ Correct|
|"The front-end should abstract the database layer"|✅ Correct|
|"Explaining this to frustrated people is hard"|✅ Also correct|

**You're right on all counts. The challenge is framing it in a way that lands.**

---

## Final Thought

> _"The fact that there are many confusing, coded fields in the data tables is not a failure of the database. It is a failure of the front-end."_

**This is the line.** It's clear. It's true. It shifts the conversation from "the database is bad" to "the interface is inadequate."

The database is doing its job. The front-end hasn't been doing its job. You're building the front-end that should have existed all along.

**That's not defensive. That's a diagnosis.**
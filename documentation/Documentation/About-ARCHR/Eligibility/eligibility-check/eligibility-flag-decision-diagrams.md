# Eligibility Flag Decision Diagrams

Every colored end node below represents a flag attached to a Report Program record.
Labels describe what staff see; Airtable field names and record IDs are intentionally omitted.

## Legend

- Green: a favorable condition was confirmed.
- Red: a configured restriction was not met.
- Yellow: the program did not provide a restriction.
- Orange: the applicant did not provide information needed for the comparison.

## Service Area

The same scale check runs independently for state, county, city, and neighborhood.

```mermaid
flowchart TD
    A[Start one geographic scale] --> B{Did the program specify an allowed area?}
    B -- No, state --> NS[Program has no state restriction]
    B -- No, county --> NC[Program has no county restriction]
    B -- No, city --> NCI[Program has no city restriction]
    B -- No, neighborhood --> NN[Program has no neighborhood restriction]
    B -- Yes --> C{Did the applicant provide that location?}
    C -- No, state --> MS[Applicant state is missing]
    C -- No, county --> MC[Applicant county is missing]
    C -- No, city --> MCI[Applicant city is missing]
    C -- No, neighborhood --> MN[Applicant neighborhood is missing]
    C -- Yes --> D{Is the applicant location in the allowed list?}
    D -- No --> OUT[Outside the service area]
    D -- Yes --> E[This geographic scale matches]

    E --> F{After all four scales are checked}
    F -- At least one match; no mismatch; no required value missing --> IN[In the service area]
    F -- Any mismatch --> OUT
    F -- Any required value missing --> WAIT[No overall service-area confirmation]

    classDef good fill:#d9f2df,stroke:#287a3d,color:#163d21;
    classDef bad fill:#f9dddd,stroke:#a63737,color:#541b1b;
    classDef omission fill:#fff1bf,stroke:#9b7400,color:#4f3b00;
    classDef missing fill:#ffe2bd,stroke:#a45b00,color:#532f00;
    class IN good;
    class OUT bad;
    class NS,NC,NCI,NN omission;
    class MS,MC,MCI,MN missing;
```

North Carolina, N. Carolina, and NC are treated as the same state. The word
“County” and the prefixes “City of” and “Town of” are ignored during comparison.

## Income

Programs may supply more than one income basis. Any passing basis is sufficient.

```mermaid
flowchart TD
    A[Start income review] --> B{Did the program provide any income limit?}
    B -- No --> NR[Program has no income restriction]
    B -- Yes --> C[Check every configured income basis]
    C --> D{Does the applicant have a value for this basis?}
    D -- No --> MV[Applicant income value is missing]
    D -- Yes --> E{Is the value at or below the program maximum?}
    E -- Yes --> WITHIN[Below the program income maximum]
    E -- No --> F[Remember that this basis exceeded the maximum]
    F --> G{After every basis is checked}
    G -- At least one basis passed --> WITHIN
    G -- At least one basis was missing --> HOLD[No over-income flag]
    G -- Every basis had a value and exceeded its maximum --> OVER[Over the program income maximum]

    classDef good fill:#d9f2df,stroke:#287a3d,color:#163d21;
    classDef bad fill:#f9dddd,stroke:#a63737,color:#541b1b;
    classDef omission fill:#fff1bf,stroke:#9b7400,color:#4f3b00;
    classDef missing fill:#ffe2bd,stroke:#a45b00,color:#532f00;
    class WITHIN good;
    class OVER bad;
    class NR omission;
    class MV missing;
```

## Ownership Profiles

A program may define alternative ownership profiles. The first profile with no
failed restriction is used. When none passes, failure evidence from every profile
is retained.

```mermaid
flowchart TD
    A[Start ownership review] --> B{Did the program provide an ownership profile?}
    B -- No --> NH[Program has no home-ownership restriction]
    B -- No --> NL[Program has no lot-ownership restriction]
    B -- Yes --> C[Evaluate each ownership profile]
    C --> D{Did any profile avoid all failures?}
    D -- Yes --> E[Use the first passing profile and its flags]
    D -- No --> F[Keep failure evidence and flags from all profiles]

    classDef omission fill:#fff1bf,stroke:#9b7400,color:#4f3b00;
    class NH,NL omission;
```

The former “Program has no ownership restrictions” flag is retired and is not
produced. The two more specific omission flags above are produced instead.

### Home Type

```mermaid
flowchart TD
    A[Check the selected ownership profile] --> B{Did the program list allowed home types?}
    B -- No --> NR[Program has no home-type restriction]
    B -- Yes --> C{Did the applicant provide a home type?}
    C -- No --> MV[Applicant home type is missing]
    C -- Yes --> D{Is the applicant home type in the allowed list?}
    D -- Yes --> OK[Eligible home type]
    D -- No --> BAD[Ineligible home type]

    classDef good fill:#d9f2df,stroke:#287a3d,color:#163d21;
    classDef bad fill:#f9dddd,stroke:#a63737,color:#541b1b;
    classDef omission fill:#fff1bf,stroke:#9b7400,color:#4f3b00;
    classDef missing fill:#ffe2bd,stroke:#a45b00,color:#532f00;
    class OK good;
    class BAD bad;
    class NR omission;
    class MV missing;
```

### Building Value

```mermaid
flowchart TD
    A[Check the selected ownership profile] --> B{Did the program set a maximum building value?}
    B -- No --> NR[Program has no building-value restriction]
    B -- Yes --> C{Did the applicant provide a numeric building value?}
    C -- No --> MV[Applicant building value is missing]
    C -- Yes --> D{Is the value at or below the maximum?}
    D -- Yes --> OK[Below the maximum building value]
    D -- No --> BAD[Over the maximum building value]

    classDef good fill:#d9f2df,stroke:#287a3d,color:#163d21;
    classDef bad fill:#f9dddd,stroke:#a63737,color:#541b1b;
    classDef omission fill:#fff1bf,stroke:#9b7400,color:#4f3b00;
    classDef missing fill:#ffe2bd,stroke:#a45b00,color:#532f00;
    class OK good;
    class BAD bad;
    class NR omission;
    class MV missing;
```

### Primary Residence

```mermaid
flowchart TD
    A[Check the selected ownership profile] --> B{Did the program require a primary-residence answer?}
    B -- No --> NR[Program has no primary-residence restriction]
    B -- Yes --> C{Did the applicant answer?}
    C -- No --> MV[Applicant primary-residence answer is missing]
    C -- Yes --> D{Does the answer match the program requirement?}
    D -- Yes, applicant answered Yes --> OK[Applicant lives in the primary residence]
    D -- Yes, applicant answered No --> NONE[No positive or negative flag]
    D -- No, applicant answered No --> BAD[Not the applicant's primary residence]
    D -- No, applicant answered Yes --> NONE2[Profile fails, but no named residence flag]

    classDef good fill:#d9f2df,stroke:#287a3d,color:#163d21;
    classDef bad fill:#f9dddd,stroke:#a63737,color:#541b1b;
    classDef omission fill:#fff1bf,stroke:#9b7400,color:#4f3b00;
    classDef missing fill:#ffe2bd,stroke:#a45b00,color:#532f00;
    class OK good;
    class BAD bad;
    class NR omission;
    class MV missing;
```

### Home Ownership

```mermaid
flowchart TD
    A[Check the selected ownership profile] --> B{Did the program require a home-ownership answer?}
    B -- No --> NR[Program has no home-ownership restriction]
    B -- Yes --> C{Did the applicant answer?}
    C -- No --> MV[Applicant home-ownership answer is missing]
    C -- Yes --> D{Does the answer match the program requirement?}
    D -- Yes, applicant answered Yes --> OK[Applicant owns the home]
    D -- Yes, applicant answered No --> NONE[No positive or negative flag]
    D -- No, applicant answered No --> BAD[Applicant does not own the home]
    D -- No, applicant answered Yes --> NONE2[Profile fails, but no named ownership flag]

    classDef good fill:#d9f2df,stroke:#287a3d,color:#163d21;
    classDef bad fill:#f9dddd,stroke:#a63737,color:#541b1b;
    classDef omission fill:#fff1bf,stroke:#9b7400,color:#4f3b00;
    classDef missing fill:#ffe2bd,stroke:#a45b00,color:#532f00;
    class OK good;
    class BAD bad;
    class NR omission;
    class MV missing;
```

### Mobile-Home Lot Ownership

```mermaid
flowchart TD
    A[Check the selected ownership profile] --> B{Did the program require a lot-ownership answer?}
    B -- No --> NR[Program has no lot-ownership restriction]
    B -- Yes --> C{Did the applicant answer?}
    C -- No --> MV[Applicant lot-ownership answer is missing]
    C -- Yes --> D{Does the answer match the program requirement?}
    D -- Yes, applicant answered Yes --> OK[Applicant owns the mobile-home lot]
    D -- Yes, applicant answered No --> NONE[No positive or negative flag]
    D -- No, applicant answered No --> BAD[Applicant does not own the mobile-home lot]
    D -- No, applicant answered Yes --> NONE2[Profile fails, but no named lot flag]

    classDef good fill:#d9f2df,stroke:#287a3d,color:#163d21;
    classDef bad fill:#f9dddd,stroke:#a63737,color:#541b1b;
    classDef omission fill:#fff1bf,stroke:#9b7400,color:#4f3b00;
    classDef missing fill:#ffe2bd,stroke:#a45b00,color:#532f00;
    class OK good;
    class BAD bad;
    class NR omission;
    class MV missing;
```

### Ownership Duration

```mermaid
flowchart TD
    A[Check the selected ownership profile] --> B{Did the program set a minimum ownership duration?}
    B -- No --> NR[Program has no minimum-duration restriction]
    B -- Yes --> C{Did the applicant provide a numeric duration?}
    C -- No --> MV[Applicant ownership duration is missing]
    C -- Yes --> D{Is the duration at or above the minimum?}
    D -- Yes --> OK[Meets the minimum ownership duration]
    D -- No --> BAD[Below the minimum ownership duration]

    classDef good fill:#d9f2df,stroke:#287a3d,color:#163d21;
    classDef bad fill:#f9dddd,stroke:#a63737,color:#541b1b;
    classDef omission fill:#fff1bf,stroke:#9b7400,color:#4f3b00;
    classDef missing fill:#ffe2bd,stroke:#a45b00,color:#532f00;
    class OK good;
    class BAD bad;
    class NR omission;
    class MV missing;
```

## Demographics

```mermaid
flowchart TD
    A[Start demographic review] --> B{Did the program provide demographic groups?}
    B -- No --> NR[Program has no demographic restriction]
    B -- Yes --> C{Is the program rule required or prioritized?}

    C -- Required --> D{Did the applicant provide demographic information?}
    D -- No --> MV[Applicant demographic information is missing]
    D -- Yes --> E{Does at least one required group match?}
    E -- Yes --> OK[Required demographic group matched]
    E -- No --> BAD[Required demographic group did not match]

    C -- Prioritized --> F{Does at least one priority group match?}
    F -- Yes --> PRI[Priority demographic group matched]
    F -- No --> NONE[No flag; lack of a priority match is not disqualifying]

    C -- Another rule type --> OTHER[No blocking flag]

    classDef good fill:#d9f2df,stroke:#287a3d,color:#163d21;
    classDef bad fill:#f9dddd,stroke:#a63737,color:#541b1b;
    classDef omission fill:#fff1bf,stroke:#9b7400,color:#4f3b00;
    classDef missing fill:#ffe2bd,stroke:#a45b00,color:#532f00;
    class OK,PRI good;
    class BAD bad;
    class NR omission;
    class MV missing;
```

## Important Interpretation Notes

1. A yellow flag describes missing program criteria. It does not mean the applicant failed.
2. An orange flag describes missing applicant data. It prevents confirmation of the corresponding green flag but is not itself a red failure.
3. A Report Program record can receive several flags from the same decision area.
4. Repeated detections of the same condition are collapsed to one linked flag, while the detailed report retains the supporting evidence.
5. Neighborhood omission and missing-data flags must exist in the FlagList before they can be linked. Until then, they appear only as unconfigured evidence.

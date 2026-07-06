# Calculated Fields — IRA Compliance Dashboard

This document details the calculated fields used to power the 
apprentice/journeyman ratio compliance logic, week-ending date 
handling, and violation flagging in the dashboard.

---

## Headcount

### Distinct count of Employee ID
**Purpose:** Give the employee count (for a given day in the visualization).

**Formula:**
```
COUNTD([Employee ID])
```

**Notes:** Distinct count is done because employees may show up multiple times per day or per week either because they worked multiple days (weekly count) or multiple classifications / crafts in a day (daily count).

---

## Apprentice Count

### Distinct count of Apprentice Employee IDs
**Purpose:** Give the apprentice count (for a given day in the visualization).

**Formula:**
```
COUNTD(if [Classification Calc] = "Apprentice" then [Employee ID] END)
```

**Notes:** Distinct count is done because employees may show up multiple times per day or per week either because they worked multiple days (weekly count) or multiple classifications / crafts in a day (daily count).

---

## JW Count

### Distinct count of Journeyman (Journeyworker) Employee IDs
**Purpose:** Give the journeyman count (for a given day in the visualization).

**Formula:**
```
COUNTD(if [Classification Calc] = "Journeyman" then [Employee ID] END)
```

**Notes:** Distinct count is done because employees may show up multiple times per day or per week either because they worked multiple days (weekly count) or multiple classifications / crafts in a day (daily count).

---

## Ratio Classifications ("Classification Calc")

### Apprentice, Journeyman, or 0 (None)
**Purpose:** Classify employee timecard distinction of hours - three options are the output of this formula.

**Formula:**
​```
if
[Classification] = "Apprentice - Disqualified" or [Classification] = "Apprentice - Disqualified Ratio" or [Classification] = "Apprentice - Disqualified Scope"
or [Classification] = "0"
or ([Classification] = "Apprentice Operator" AND [Craft] = "Laborer")
or ([Classification] = "Apprentice Laborer" AND [Craft] = "Operator")
or ([Classification] = "Apprentice Laborer" AND [Craft] = "Electrician")
or ([Classification] = "Apprentice Electrician" AND [Craft] = "Laborer")
or ([Classification] = "Journeyman Electrician" AND [Craft] = "Laborer")
or ([Classification] = "Journeyman Operator" AND [Craft] = "Laborer")
or ([Classification] = "Apprentice CCL and Electrician" AND [Craft] = "Operator")
or ([Classification] = "Apprentice CCL and Operator" AND [Craft] = "Electrician")
or ([Classification] = "Journeyman CCL and Electrician" AND [Craft] = "Operator")
or ([Classification] = "Journeyman CCL and Operator" AND [Craft] = "Electrician")
or ([Classification] = "Journeyman Laborer" AND [Craft] = "Operator")
or ([Classification] = "Journeyman Laborer" AND [Craft] = "Electrician")
or ([Classification] = "Laborer" AND [Craft] = "Operator")
or [Classification] = "Laborer"
or [Craft] = "0"
then
"0"
elseif
[Classification] = "Apprentice"
or RIGHT([Classification],11) = "Requalified"
OR LEFT([Classification],11) = "Apprentice " AND RIGHT([Classification Descr],12) != "Disqualified"
then
"Apprentice"
ELSEIF 
[Classification] = "Journeyman"
OR LEFT([Classification],11) = "Journeyman "
then
"Journeyman"
END
​```

**Notes:** 
Employees can be working "out of scope" which is when the latter half of their classification does not match the craft they work under that day.
For instance an "Apprentice Opeator" that works as a "Laborer" for a day does not fit within the scope of the project and are not to be counted when considering staffing ratios. 
"CCL" is shorthand in the system for "Construction Craft Laborer" which is the same as "Laborer".
Employees can also have their hours requalified - designated by "Requalified"
Any time the "Disqualified" moniker is given in the classification it is always changes the classification to "0" which is the same as no classification.

---

## Week-Ending Date Logic

### Week Ending Date
**Purpose:** Convert transaction dates into Saturday-anchored week-ending dates to match industry-standard payroll reporting weeks.

**Formula:**
​```
DATEADD('day', -1, DATEADD('week', 1, DATETRUNC('week', [Date])))
​```

**Notes:** Groups all transactions from Sunday through Saturday into the same week-ending Saturday. Used for weekly aggregations across the dashboard.

---

## Compliance Status Flag

### Ratio Compliance Status
**Purpose:** Count the number of apprentices vs journeyman for IRA compliance.

**Formula:**
​```
IFNULL(COUNTD(if [Classification Calc]= "Apprentice" AND [Craft Name] = "Carpenter" then [Employee ID]END),0)
<=
IFNULL(COUNTD(if [Classification Calc] = "Journeyman" AND [Craft Name] = "Carpenter" then [Employee ID]END),0)
​```

**Notes:** Craft Names are subsituted to provide a specific calc for each craft. Translated from boolean T/F to "Yes / No" in "IRA Compliant (Craft Name) function".

---

## Overage Calculator

### Overage of Apprentices (vs Journeyman) if present
**Purpose:** Determine the overage of apprentices so that compliance teams can see the number of apprentices that need to be disqualified for a given day and project.

**Formula:**
```
[Apprentice Count]-[JW Count]
```

**Notes:** Used on the "Ratio Errors Dashboard" for the overage amounts in the table as well as the details in the tooltip.

---
## Ratio Summary

### Total Ratio Calculation
**Purpose:** Determine the overall ratio compliance for an entire project, or all projects if all are selected through the dropdown filters.

**Formula:**
```
if [IRA Compliant (Labor)] = 
FALSE 
OR
[IRA Compliant (Oper)] = 
FALSE
OR
[IRA Compliant (Electr)] = 
FALSE
OR
[IRA Compliant (Mech)] =
FALSE
OR
[IRA Compliant (Carp)] =
FALSE
then
"NO"
ELSEIF [IRA Compliant (Labor)] = 
TRUE
OR
[IRA Compliant (Oper)] = 
TRUE
OR
[IRA Compliant (Electr)] = 
TRUE
OR
[IRA Compliant (Carp)] = 
TRUE
OR
[IRA Compliant (Mech)] = 
TRUE
Then
"YES"
END
```

**Notes:** Present in the "Summary" section of the IRA Dashboard under the "Ratio Satisfied?" row. Designed to list a "No" if any of the 5 crafts are out of ratio for a given date.

---

## Compliance Boolean Translation

### Ratio compliance "Yes" / "No"
**Purpose:** Translate T/F values derived from Ratio Complaince calcs into a more user-friendly "Yes" / "No" format to track daily compliance.

```
if ISNULL([IRA Compliant (Carpenter)])
or [IRA Compliant (Carpenter)] = FALSE
then
"NO"
ELSE
"YES"
END
```

**Notes:** Craft Names are subsituted to provide a specific calc for each craft.

---

## Notes on Formulas

All formulas are written in Tableau's calculation syntax. Field 
names in square brackets reference source data columns. Aggregation 
functions (SUM, COUNT) are applied at the visualization level 
rather than within the calculated field where possible.

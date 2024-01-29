# bill cal

A Flutter project to help powerhouse staff with calculating electricity bills.

# To-Do
- Support all CRUD operations for consumer categories.
  - ~~Create Category~~
  - ~~Read Category~~
  - ~~Delete Category~~
  - Update Category
- Handle the remaining units case i.e. when adding a category, allow the option (or maybe it should be strictly required when the category does not have a flat rate) to add a final rate for all the remaining units that remain after all the rate brackets of the same category has been applied.
  - this is for now handled by using the latest rate to apply to the remaining units.
- In the calculator, provide a 'clear all' button that clears all the filled values (currently, these would be the 'last reading' and 'new reading' fields).
  - By default, hold on to the values the user puts inside the 'last reading' and 'new reading' fields if they switch to another screen.
- Add field validations for the calculator page as well.
  - New Reading should be greater than Last Reading.
- Recalculate new bill value when another category is selected only when the calculate bill button has been clicked at least once.
- If the calculate bill button has been clicked then update its look to indicate that, and update that look and feel whenever a category is changed.
- add error handling (try catch?)


# Performance Improvements (though it might not matter at this stage)

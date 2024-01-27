# bill cal

A Flutter project to help powerhouse staff with calculating electricity bills.

# To-Do
- Support all CRUD operations for consumer categories.
  - ~~Create Category~~
  - ~~Read Category~~
  - ~~Delete Category~~
  - Update Category
- Handle the remaining units case i.e. when adding a category, allow the option (or maybe it should be strictly required when the category does not have a flat rate) to add a final rate for all the remaining units that remain after all the rate brackets of the same category has been applied.
- In the calculator, provide a 'clear all' button that clears all the filled values (currently, these would be the 'last reading' and 'new reading' fields).
  - By default, hold on to the values the user puts inside the 'last reading' and 'new reading' fields if they switch to another screen.
- Add field validations for the calculator page as well.
  - New Reading should be greater than Last Reading.

# Jog Tracking REST API Endpoint

This repo consists of an API endpoint that allows end-users to track their jog/run events:
Provided functionality includes:

* API Users can create an account and log in.
* All API calls are authenticated.
* Implemented three roles with different permission levels: a regular user can CRUD on their owned records, a user manager can CRUD only users, and an admin can CRUD all records and users.
* Each time entry has a date, distance, time, and location.
* Based on the provided date and location, API connects to a weather API provider and gets the weather conditions for the run, and stores that with each run.
* The API returns a report on average speed & distance per week.
* The API returns data in the JSON format.
* The API provides filter capabilities for all endpoints that return a list of elements, as well supports pagination.
* The API filtering allows using parenthesis for defining operations precedence and uses any combination of the available fields. The supported operations should include or, and, eq (equals), ne (not equals), gt (greater than), lt (lower than). Example -> (date eq '2016-05-01') AND ((distance gt 20) OR (distance lt 10)).
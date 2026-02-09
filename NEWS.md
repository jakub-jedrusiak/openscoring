# openscoring 1.0.6

* Empty strings now have NA score instead of 1.

# openscoring 1.0.5

* Renamed `oscai()` to `ocsai()` (how I didn't notice this earlier still puzzles me)
* If the request line is too large, the function now splits the request in multiple parts
* Added the `chunk_size` argument to `ocsai()`
* `ocsai()` now checks if columns exist
* Input sanitation is now better

# openscoring 1.0.4

* Added the `ocsai-1.6` model
* Added the `ocsai1-4o` model
* The function now fails gracefully when the server is not available

# openscoring 1.0.3

* Long databases are now split before being sent to the server
* Added the `language` argument to `ocsai()`
* Updated the available models

# openscoring 1.0.2

* Added ocsai-1.5 model
* Debuged CA problems

# openscoring 1.0.1

* Added tests
* Added URLs to `DESCRIPTION` file
* Added Pier-Luc de Chantal as contributor

# openscoring 1.0.0

* Initial CRAN submission.

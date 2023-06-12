# FG-Uschi - Getränkekasse
This is a fork of the neat fsikasse. Mainly it was optimised for the use case of the "Fachgruppe Umweltschutztechnik" at the University of Stuttgart. Readme will be updated soon, as there are some updates to the repo itself.

## Description

A neat little web application that manages the sale and stock of drinks and sweets. It is designed to run on a Windows 10 tablet with a resolution of 1920x1200 (Chuwi Hi8 Pro). All users are expected to be trusted and "well behaved". It was meant to have (at least) the same feature set as the paper tally sheet, which it replaced.

## Installation

Install dependencies:

    $ pip install -U Flask Flask-BasicAuth Pillow Pandas Matplotlib

[Download](https://github.com/legeiger/ving-kasse/archive/master.zip) and extract ving-kasse or clone the git repository.

    $ git clone https://github.com/legeiger/ving-kasse.git
    $ cd ving-kasse

Setup vingkasse:

    $ FLASK_APP=vingkasse flask initdb
	> set FLASK_APP=vingkasse
	> flask initdb

From now on it is sufficient to start vingkasse with:

    $ FLASK_APP=vingkasse flask run
	> flask run

To use the development environment:

	$ FLASK_ENV=development
	> set FLASK_ENV=development
	
## Update (experimental)

If you have cloned the repository, you can run the following commands to update the vingkasse:

    $ pip install -U Flask
    $ pip install -U Pillow
    $ git pull

Don't forget the restart flask.

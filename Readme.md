# FSI-Kasse

## Description

A neat little web application that manages the sale and stock of drinks and sweets. It is designed to run on a single machine, all users are expected to be trusted and "well behaved". It was meant to have (at least) the same feature set as the paper tally sheet, which it replaced.

## Installation

Install dependencies:

    $ pip install -U Flask Pillow Pandas Matplotlib

[Download](https://github.com/FSI-CE/fsikasse/archive/master.zip) and extract fsikasse or clone the git repository.

    $ git clone https://github.com/FSI-CE/fsikasse.git
    $ cd fsikasse

Setup fsikasse:

    $ FLASK_APP=fsikasse.py flask initdb

From now on it is sufficient to start fsikasse with:

    $ FLASK_APP=fsikasse.py flask run

## Update (experimental)

If you have cloned the repository, you can run the following commands to update the fsikasse:

    $ pip install -U Flask
    $ pip install -U Pillow
    $ git pull

Don't forget the restart flask.

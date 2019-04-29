set FLASK_APP=vingkasse
REM set FLASK_ENV=development
flask initdb
flask run --host=0.0.0.0

:End
cmd /k
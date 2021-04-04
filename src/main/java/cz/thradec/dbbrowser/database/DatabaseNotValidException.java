package cz.thradec.dbbrowser.database;

import org.springframework.dao.DataAccessResourceFailureException;

import static java.lang.String.format;

class DatabaseNotValidException extends DataAccessResourceFailureException {

    DatabaseNotValidException(Database database, Throwable cause) {
        super(format("Connection to database [%s] failed, check url [%s] and credentials.",
                database.getName(), database.getUrl()), cause);
    }

}
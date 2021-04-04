package cz.thradec.dbbrowser.database;

import org.springframework.dao.DataRetrievalFailureException;

import static java.lang.String.format;

class DatabaseNotFoundException extends DataRetrievalFailureException {

    DatabaseNotFoundException(String name) {
        this(name, null);
    }

    DatabaseNotFoundException(String name, Throwable cause) {
        super(format("Database with name [%s] not found.", name), cause);
    }

}
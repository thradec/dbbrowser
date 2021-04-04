package cz.thradec.dbbrowser.database;

import lombok.RequiredArgsConstructor;
import org.jooq.DSLContext;
import org.jooq.Field;
import org.jooq.Table;
import org.jooq.exception.NoDataFoundException;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.jooq.impl.DSL.*;

@Repository
@Transactional
@RequiredArgsConstructor
class DatabaseRepository {

    private static final Table DATABASE = table(name("database"));
    private static final Field NAME = field("name");
    private static final Field URL = field("url");
    private static final Field USERNAME = field("username");
    private static final Field PASSWORD = field("password");

    private final DSLContext jooq;

    public List<Database> findAll() {
        return jooq.selectFrom(DATABASE)
                .orderBy(NAME.asc())
                .fetch()
                .into(Database.class);
    }

    public Database findByName(String databaseName) {
        try {
            return jooq.selectFrom(DATABASE)
                    .where(NAME.eq(databaseName))
                    .fetchSingle()
                    .into(Database.class);
        } catch (NoDataFoundException e) {
            throw new DatabaseNotFoundException(databaseName, e);
        }
    }

    public void save(Database database) {
        jooq.insertInto(DATABASE, NAME, URL, USERNAME, PASSWORD)
                .values(database.getName(), database.getUrl(), database.getUsername(), database.getPassword())
                .onConflict(NAME)
                .doUpdate()
                .set(URL, database.getUrl())
                .set(USERNAME, database.getUsername())
                .set(PASSWORD, database.getPassword())
                .execute();
    }

    public void delete(String databaseName) {
        var rows = jooq.deleteFrom(DATABASE)
                .where(NAME.eq(databaseName))
                .execute();
        if (rows == 0) {
            throw new DatabaseNotFoundException(databaseName);
        }
    }

}
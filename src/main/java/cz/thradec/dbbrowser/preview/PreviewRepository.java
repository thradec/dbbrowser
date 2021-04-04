package cz.thradec.dbbrowser.preview;

import cz.thradec.dbbrowser.database.DatabaseConnector;
import lombok.RequiredArgsConstructor;
import org.jooq.Field;
import org.jooq.JSONFormat;
import org.jooq.Record;
import org.jooq.Result;
import org.springframework.dao.DataRetrievalFailureException;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Stream;

import static java.lang.String.format;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;
import static org.jooq.JSONFormat.RecordFormat.OBJECT;
import static org.jooq.impl.DSL.name;
import static org.springframework.util.StringUtils.hasLength;

@Repository
@Transactional
@RequiredArgsConstructor
class PreviewRepository {

    private static final int NUMBER_OF_ROWS = 100;

    private final DatabaseConnector databaseConnector;

    public Preview findPreview(String databaseName, String schemaName, String tableName) {
        return databaseConnector.execute(databaseName, jooq -> {
            try {
                var result = jooq.create()
                        .select()
                        .from(name(schemaName, tableName))
                        .limit(NUMBER_OF_ROWS)
                        .offset(0)
                        .fetch();
                return Preview.builder()
                        .table(tableName)
                        .columns(mapColumns(result))
                        .rows(mapRows(result))
                        .build();
            } catch (RuntimeException e) {
                throw new DataRetrievalFailureException(format("Retrieving preview of table [%s] from database [%s] failed.",
                        Stream.of(schemaName, tableName).filter(it -> hasLength(it)).collect(joining(".")), databaseName), e);
            }
        });
    }

    private List<String> mapColumns(Result<Record> result) {
        return Arrays.stream(result.fields())
                .map(Field::getName)
                .collect(toList());
    }

    private String mapRows(Result<Record> result) {
        return result.formatJSON(
                new JSONFormat()
                        .header(false)
                        .recordFormat(OBJECT));
    }

}
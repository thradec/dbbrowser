package cz.thradec.dbbrowser.metadata;

import org.jooq.meta.Database;
import org.jooq.meta.TableDefinition;
import org.springframework.dao.DataRetrievalFailureException;
import org.springframework.stereotype.Component;

import java.util.List;

import static java.lang.String.format;
import static java.util.stream.Collectors.toList;

@Component
public class TableDefinitionResolver {

    public List<TableDefinition> findTables(Database jooq, String databaseName, String schemaName, String tableName) {
        List<TableDefinition> tableDefs;
        var schemaDef = jooq.getSchema(schemaName);
        if (schemaName != null && schemaDef == null) {
            throw new DataRetrievalFailureException(format("Schema [%s] not found in database [%s]", schemaName, databaseName));
        }
        if (tableName != null) {
            var tableDef = jooq.getTable(schemaDef, tableName);
            if (tableDef == null) {
                throw new DataRetrievalFailureException(format("Table [%s] not found in database [%s]", tableName, databaseName));
            }
            tableDefs = List.of(tableDef);
        } else {
            tableDefs = jooq.getTables(schemaDef);
        }
        return tableDefs.stream()
                .filter(tableDef -> !tableDef.isView() && !tableDef.isMaterializedView() && !tableDef.isTableValuedFunction())
                .collect(toList());
    }

}

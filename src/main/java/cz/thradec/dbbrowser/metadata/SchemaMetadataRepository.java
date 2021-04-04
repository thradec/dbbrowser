package cz.thradec.dbbrowser.metadata;

import cz.thradec.dbbrowser.database.DatabaseConnector;
import lombok.RequiredArgsConstructor;
import org.jooq.meta.Database;
import org.jooq.meta.Definition;
import org.jooq.meta.SchemaDefinition;
import org.springframework.dao.DataRetrievalFailureException;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static java.lang.String.format;
import static java.util.stream.Collectors.toList;

@Repository
@Transactional
@RequiredArgsConstructor
class SchemaMetadataRepository {

    private final DatabaseConnector databaseConnector;

    public List<SchemaMetadata> findSchemasMetadata(String databaseName, String schemaName) {
        return databaseConnector.execute(databaseName, jooq -> {
            var schemaDefs = findSchemas(jooq, databaseName, schemaName);
            return schemaDefs.stream()
                    .map(schemaDef -> SchemaMetadata.builder()
                            .name(schemaDef.getName())
                            .qualifiedName(schemaDef.getQualifiedName())
                            .comment(schemaDef.getComment())
                            .catalog(schemaDef.getCatalog().getName())
                            .tables(schemaDef.getTables()
                                    .stream()
                                    .filter(t -> !t.isView() && !t.isMaterializedView() && !t.isTableValuedFunction())
                                    .map(Definition::getName)
                                    .collect(toList()))
                            .build())
                    .collect(toList());
        });
    }

    private List<SchemaDefinition> findSchemas(Database jooq, String databaseName, String schemaName) {
        if (schemaName == null) {
            return jooq.getSchemata();
        } else {
            var schemaDef = jooq.getSchema(schemaName);
            if (schemaDef == null) {
                throw new DataRetrievalFailureException(format("Schema [%s] not found in database [%s]", schemaName, databaseName));
            }
            return List.of(schemaDef);
        }
    }

}

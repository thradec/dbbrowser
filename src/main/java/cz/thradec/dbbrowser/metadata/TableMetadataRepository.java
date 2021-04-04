package cz.thradec.dbbrowser.metadata;

import cz.thradec.dbbrowser.database.DatabaseConnector;
import lombok.RequiredArgsConstructor;
import org.jooq.meta.Definition;
import org.jooq.meta.TableDefinition;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static java.util.stream.Collectors.toList;
import static org.springframework.util.CollectionUtils.isEmpty;

@Repository
@Transactional
@RequiredArgsConstructor
class TableMetadataRepository {

    private final DatabaseConnector databaseConnector;
    private final TableDefinitionResolver tableDefinitionResolver;

    public List<TableMetadata> findTablesMetadata(String databaseName, String schemaName, String tableName) {
        return databaseConnector.execute(databaseName, jooq -> {
            var tableDefs = tableDefinitionResolver.findTables(jooq, databaseName, schemaName, tableName);
            return tableDefs.stream()
                    .map(tableDef -> TableMetadata.builder()
                            .name(tableDef.getName())
                            .qualifiedName(tableDef.getQualifiedName())
                            .comment(tableDef.getComment())
                            .schema(tableDef.getSchema().getName())
                            .catalog(tableDef.getCatalog().getName())
                            .columns(includeDetails(tableName) ? mapColumns(tableDef) : null)
                            .primaryKey(includeDetails(tableName) ? mapPrimaryKey(tableDef) : null)
                            .uniqueKeys(includeDetails(tableName) ? mapUniqueKeys(tableDef) : null)
                            .foreignKeys(includeDetails(tableName) ? mapForeignKeys(tableDef) : null)
                            .build()).collect(toList());
        });
    }

    private List<TableMetadata.ColumnMetadata> mapColumns(TableDefinition tableDef) {
        return tableDef.getColumns()
                .stream()
                .map(columnDef -> TableMetadata.ColumnMetadata.builder()
                        .name(columnDef.getName())
                        .qualifiedName(columnDef.getQualifiedName())
                        .comment(columnDef.getComment())
                        .type(columnDef.getDefinedType().getUserType())
                        .position(columnDef.getPosition())
                        .length(columnDef.getDefinedType().getLength())
                        .precision(columnDef.getDefinedType().getPrecision())
                        .scale(columnDef.getDefinedType().getScale())
                        .isPrimaryKey(columnDef.getPrimaryKey() != null)
                        .isUniqueKey(isEmpty(columnDef.getUniqueKeys()))
                        .isForeignKey(isEmpty(columnDef.getForeignKeys()))
                        .isNullable(columnDef.getDefinedType().isNullable())
                        .isIdentity(columnDef.getDefinedType().isIdentity())
                        .isDefaulted(columnDef.getDefinedType().isDefaulted())
                        .defaultValue(columnDef.getDefinedType().getDefaultValue())
                        .build())
                .collect(toList());
    }

    private TableMetadata.UniqueKeyMetadata mapPrimaryKey(TableDefinition tableDef) {
        var primaryKeyDef = tableDef.getPrimaryKey();
        return primaryKeyDef == null ? null : TableMetadata.UniqueKeyMetadata.builder()
                .name(primaryKeyDef.getName())
                .columns(primaryKeyDef.getKeyColumns()
                        .stream()
                        .map(Definition::getName)
                        .collect(toList()))
                .build();
    }

    private List<TableMetadata.UniqueKeyMetadata> mapUniqueKeys(TableDefinition tableDef) {
        var uniqueKeysDef = tableDef.getUniqueKeys()
                .stream()
                .filter(uniqueKeyDef -> !uniqueKeyDef.isPrimaryKey())
                .collect(toList());
        return isEmpty(uniqueKeysDef) ? null : uniqueKeysDef
                .stream()
                .map(uniqueKeyDef -> TableMetadata.UniqueKeyMetadata.builder()
                        .name(uniqueKeyDef.getName())
                        .columns(uniqueKeyDef.getKeyColumns()
                                .stream()
                                .map(Definition::getName)
                                .collect(toList()))
                        .build())
                .collect(toList());
    }

    private List<TableMetadata.ForeignKeyMetadata> mapForeignKeys(TableDefinition tableDef) {
        var foreignKeysDef = tableDef.getForeignKeys();
        return isEmpty(foreignKeysDef) ? null : foreignKeysDef
                .stream()
                .map(foreignKeyDef -> TableMetadata.ForeignKeyMetadata.builder()
                        .name(foreignKeyDef.getName())
                        .table(foreignKeyDef.getTable().getName())
                        .columns(foreignKeyDef.getKeyColumns()
                                .stream()
                                .map(Definition::getName)
                                .collect(toList()))
                        .build())
                .collect(toList());
    }

    private boolean includeDetails(String tableName) {
        return tableName != null; // include details only if a specific table is requested
    }

}

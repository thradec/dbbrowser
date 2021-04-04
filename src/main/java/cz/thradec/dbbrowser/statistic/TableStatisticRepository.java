package cz.thradec.dbbrowser.statistic;

import cz.thradec.dbbrowser.database.DatabaseConnector;
import cz.thradec.dbbrowser.metadata.TableDefinitionResolver;
import lombok.RequiredArgsConstructor;
import org.jooq.DSLContext;
import org.jooq.DataType;
import org.jooq.Field;
import org.jooq.Record;
import org.jooq.exception.SQLDialectNotSupportedException;
import org.jooq.meta.ColumnDefinition;
import org.jooq.meta.Database;
import org.jooq.meta.TableDefinition;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static cz.thradec.dbbrowser.statistic.TableStatistic.ColumnStatistic;
import static java.util.stream.Collectors.toList;
import static org.jooq.impl.DSL.*;
import static org.jooq.meta.AbstractTypedElementDefinition.getDataType;

@Repository
@Transactional
@RequiredArgsConstructor
class TableStatisticRepository {

    private final DatabaseConnector databaseConnector;
    private final TableDefinitionResolver tableDefinitionResolver;

    public List<TableStatistic> findStatistics(String databaseName, String schemaName, String tableName) {
        return databaseConnector.execute(databaseName, jooq -> {
            var ctx = jooq.create();
            var tableDefs = tableDefinitionResolver.findTables(jooq, databaseName, schemaName, tableName);
            var numberOfRows = findNumberOfRows(ctx, tableDefs);
            return tableDefs.stream()
                    .map(tableDef -> TableStatistic.builder()
                            .name(tableDef.getName())
                            .qualifiedName(tableDef.getQualifiedName())
                            .numberOfRows(numberOfRows.get(tableDef))
                            .numberOfColumns(tableDef.getColumns().size())
                            .columns(includeColumnsStatistics(tableName) ? findColumnsStatistics(jooq, ctx, tableDef) : null)
                            .build()
                    )
                    .collect(toList());
        });
    }

    private Map<TableDefinition, Integer> findNumberOfRows(DSLContext ctx, List<TableDefinition> tableDefs) {
        var select = ctx.selectQuery();
        for (var tableDef : tableDefs) {
            select.unionAll(ctx.selectCount().from(tableDef.getQualifiedName()));
        }
        var numOfRowsMap = new HashMap<TableDefinition, Integer>();
        var numOfRowsResult = select.fetch();
        var numOfRowsIterator = numOfRowsResult.iterator();
        numOfRowsIterator.next(); // skip result of first select 1
        for (var tableDef : tableDefs) {
            numOfRowsMap.put(tableDef, numOfRowsIterator.next().get(0, Integer.class));
        }
        return numOfRowsMap;
    }

    private List<ColumnStatistic> findColumnsStatistics(Database jooq, DSLContext ctx, TableDefinition tableDef) {
        var select = ctx.selectQuery();
        select.addFrom(table(tableDef.getQualifiedName()));
        for (var columnDef : tableDef.getColumns()) {
            var columnType = resolveColumnType(jooq, columnDef);
            if (columnType != null) {
                Field field = field(columnDef.getName());
                if (columnType.isString() || columnType.isNumeric() || columnType.isDateTime()) {
                    select.addSelect(min(field).as(minAlias(columnDef)));
                    select.addSelect(max(field).as(maxAlias(columnDef)));
                }
                if (columnType.isNumeric()) {
                    select.addSelect(avg(field).as(avgAlias(columnDef)));
                    select.addSelect(median(field).as(medianAlias(columnDef)));
                }
            }
        }

        var record = select.fetchOne();

        return tableDef.getColumns()
                .stream()
                .map(columnDef -> ColumnStatistic.builder()
                        .name(columnDef.getName())
                        .qualifiedName(columnDef.getQualifiedName())
                        .min(resolveValue(record, minAlias(columnDef)))
                        .max(resolveValue(record, maxAlias(columnDef)))
                        .avg(resolveValue(record, avgAlias(columnDef)))
                        .median(resolveValue(record, medianAlias(columnDef)))
                        .build())
                .collect(toList());
    }

    private String minAlias(ColumnDefinition columnDef) {
        return resolveAlias("min", columnDef);
    }

    private String maxAlias(ColumnDefinition columnDef) {
        return resolveAlias("max", columnDef);
    }

    private String avgAlias(ColumnDefinition columnDef) {
        return resolveAlias("avg", columnDef);
    }

    private String medianAlias(ColumnDefinition columnDef) {
        return resolveAlias("median", columnDef);
    }

    private String resolveAlias(String prefix, ColumnDefinition columnDef) {
        return prefix + "_" + columnDef.getName();
    }

    private Object resolveValue(Record record, String alias) {
        return record.indexOf(alias) != -1 ? record.get(alias) : null;
    }

    private DataType resolveColumnType(Database jooq, ColumnDefinition columnDef) {
        try {
            return getDataType(jooq,
                    columnDef.getDefinedType().getType(),
                    columnDef.getDefinedType().getPrecision(),
                    columnDef.getDefinedType().getScale());
        } catch (SQLDialectNotSupportedException e) {
            // eg. for user-defined data types is not possible to resolve generic ones
            return null;
        }
    }

    private boolean includeColumnsStatistics(String tableName) {
        return tableName != null; // include columns statistics only if a specific table is requested
    }

}

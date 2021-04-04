package cz.thradec.dbbrowser.metadata;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
class TableMetadata {

    private final String name;
    private final String qualifiedName;
    private final String comment;
    private final String schema;
    private final String catalog;
    private final List<ColumnMetadata> columns;
    private final UniqueKeyMetadata primaryKey;
    private final List<UniqueKeyMetadata> uniqueKeys;
    private final List<ForeignKeyMetadata> foreignKeys;

    @Getter
    @Builder
    static class ColumnMetadata {
        private final String name;
        private final String qualifiedName;
        private final String comment;
        private final String type;
        private final int position;
        private final int length;
        private final int precision;
        private final int scale;
        private final boolean isPrimaryKey;
        private final boolean isUniqueKey;
        private final boolean isForeignKey;
        private final boolean isNullable;
        private final boolean isIdentity;
        private final boolean isDefaulted;
        private final String defaultValue;
    }

    @Getter
    @Builder
    static class UniqueKeyMetadata {
        private final String name;
        private final List<String> columns;
    }

    @Getter
    @Builder
    static class ForeignKeyMetadata {
        private final String name;
        private final String table;
        private final List<String> columns;
    }

}

package cz.thradec.dbbrowser.metadata;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
class SchemaMetadata {
    private final String name;
    private final String qualifiedName;
    private final String comment;
    private final String catalog;
    private final List<String> tables;
}

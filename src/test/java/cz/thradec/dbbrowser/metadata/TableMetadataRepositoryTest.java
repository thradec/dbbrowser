package cz.thradec.dbbrowser.metadata;

import cz.thradec.dbbrowser.AbstractTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataRetrievalFailureException;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class TableMetadataRepositoryTest extends AbstractTest {

    @Autowired
    private TableMetadataRepository tableMetadataRepository;

    @Test
    void findTable() {
        var tablesMetadata = tableMetadataRepository.findTablesMetadata("pagila", null, "actor");
        var actorMetadata = tablesMetadata.get(0);
        assertThat(actorMetadata).isNotNull();
        assertThat(actorMetadata.getName()).isEqualTo("actor");
        assertThat(actorMetadata.getQualifiedName()).isEqualTo("public.actor");
        assertThat(actorMetadata.getSchema()).isEqualTo("public");
        assertThat(actorMetadata.getPrimaryKey().getName()).isEqualTo("actor_pkey");
        assertThat(actorMetadata.getPrimaryKey().getColumns()).containsOnly("actor_id");
        assertThat(actorMetadata.getUniqueKeys()).isNull();
        assertThat(actorMetadata.getForeignKeys()).isNull();
        assertThat(actorMetadata.getColumns()).hasSize(4);
        var actorIdMetadata = actorMetadata.getColumns().get(0);
        assertThat(actorIdMetadata.getName()).isEqualTo("actor_id");
        assertThat(actorIdMetadata.getQualifiedName()).isEqualTo("public.actor.actor_id");
        assertThat(actorIdMetadata.getType()).isEqualTo("int4");
        assertThat(actorIdMetadata.getPosition()).isEqualTo(1);
        assertThat(actorIdMetadata.getPrecision()).isEqualTo(32);
        assertThat(actorIdMetadata.getScale()).isEqualTo(0);
        assertThat(actorIdMetadata.getLength()).isEqualTo(0);
        assertThat(actorIdMetadata.isPrimaryKey()).isTrue();
        assertThat(actorIdMetadata.isNullable()).isFalse();
    }

    @Test
    void findTableThrowsRetrievalException() {
        assertThatThrownBy(() -> tableMetadataRepository.findTablesMetadata("pagila", null, "oops"))
                .isInstanceOf(DataRetrievalFailureException.class);
    }

    @Test
    void crawler() {
        var tables = tableMetadataRepository.findTablesMetadata("pagila", null, null);
        for (var table : tables) {
            var tableWithColumns = tableMetadataRepository.findTablesMetadata("pagila", table.getSchema(), table.getName());
            assertThat(tableWithColumns.get(0).getName()).isNotEmpty();
            assertThat(tableWithColumns.get(0).getColumns()).isNotEmpty();
        }
    }

}
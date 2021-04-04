package cz.thradec.dbbrowser.metadata;

import cz.thradec.dbbrowser.AbstractTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataRetrievalFailureException;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class SchemaMetadataRepositoryTest extends AbstractTest {

    @Autowired
    private SchemaMetadataRepository schemaMetadataRepository;

    @Test
    void findSchemasMetadata() {
        var schemas = schemaMetadataRepository.findSchemasMetadata("pagila", null);
        assertThat(schemas).hasSize(6);
        assertThat(schemas.stream().map(s -> s.getName())).contains("public");
    }

    @Test
    void findSchemasMetadataNamely() {
        var schema = schemaMetadataRepository.findSchemasMetadata("pagila", "public");
        assertThat(schema).hasSize(1);
        assertThat(schema.get(0).getName()).isEqualTo("public");
        assertThat(schema.get(0).getTables()).hasSize(21);
        assertThat(schema.get(0).getTables()).contains("actor", "film", "store");
    }

    @Test
    void findSchemasMetadataThrowsRetrievalException() {
        assertThatThrownBy(() -> schemaMetadataRepository.findSchemasMetadata("pagila", "oops"))
                .isInstanceOf(DataRetrievalFailureException.class);
    }

}
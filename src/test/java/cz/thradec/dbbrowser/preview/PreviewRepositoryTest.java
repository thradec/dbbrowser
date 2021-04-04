package cz.thradec.dbbrowser.preview;

import cz.thradec.dbbrowser.AbstractTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataRetrievalFailureException;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class PreviewRepositoryTest extends AbstractTest {

    @Autowired
    private PreviewRepository previewRepository;

    @Test
    void findPreview() {
        var result = previewRepository.findPreview("pagila", null, "actor");
        assertThat(result.getTable()).isEqualTo("actor");
        assertThat(result.getColumns()).contains("actor_id", "first_name", "last_name", "last_update");
        assertThat(result.getRows()).contains("{\"actor_id\":1,\"first_name\":\"PENELOPE\",\"last_name\":\"GUINESS\",\"last_update\":\"2006-02-15 09:34:33.0\"}");
    }

    @Test
    void findPreviewThrowsRetrievalException() {
        assertThatThrownBy(() -> previewRepository.findPreview("pagila", null, "oops"))
                .isInstanceOf(DataRetrievalFailureException.class);
    }

}
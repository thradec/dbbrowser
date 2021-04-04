package cz.thradec.dbbrowser.preview;

import cz.thradec.dbbrowser.AbstractTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.http.MediaType.APPLICATION_PROBLEM_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class PreviewControllerTest extends AbstractTest {

    @Autowired
    private MockMvc mvc;

    @Test
    void getPreview() throws Exception {
        mvc.perform(get("/api/tables/preview")
                .param("databaseName", "pagila")
                .param("tableName", "actor"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(APPLICATION_JSON))
                .andExpect(jsonPath("$.data.table").value("actor"))
                .andExpect(jsonPath("$.data.columns", hasSize(4)))
                .andExpect(jsonPath("$.data.rows", hasSize(100)))
                .andExpect(jsonPath("$.data.rows[0].actor_id").value(1))
                .andExpect(jsonPath("$.data.rows[0].first_name").value("PENELOPE"))
                .andExpect(jsonPath("$.data.rows[0].last_name").value("GUINESS"));
    }

    @Test
    void getReturns400WhenTableNotPresent() throws Exception {
        mvc.perform(get("/api/tables/preview")
                .param("databaseName", "pagila"))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentType(APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.detail").value(startsWith("Required String parameter 'tableName' is not present")));
    }

    @Test
    void getReturns404WhenTableNotFound() throws Exception {
        mvc.perform(get("/api/tables/preview")
                .param("databaseName", "pagila")
                .param("tableName", "oops"))
                .andExpect(status().isNotFound())
                .andExpect(content().contentType(APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.detail").value(startsWith("Retrieving preview of table [oops] from database [pagila] failed")));
    }

}
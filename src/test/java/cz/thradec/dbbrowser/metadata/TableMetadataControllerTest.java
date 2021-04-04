package cz.thradec.dbbrowser.metadata;

import cz.thradec.dbbrowser.AbstractTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.startsWith;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.http.MediaType.APPLICATION_PROBLEM_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class TableMetadataControllerTest extends AbstractTest {

    @Autowired
    private MockMvc mvc;

    @Test
    void getOne() throws Exception {
        mvc.perform(get("/api/tables/metadata")
                .param("databaseName", "pagila")
                .param("schemaName", "public")
                .param("tableName", "actor"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(APPLICATION_JSON))
                .andExpect(jsonPath("$.data[0].name").value("actor"))
                .andExpect(jsonPath("$.data[0].schema").value("public"))
                .andExpect(jsonPath("$.data[0].columns[0].name").value("actor_id"))
                .andExpect(jsonPath("$.data[0].columns[0].type").value("int4"))
                .andExpect(jsonPath("$.data[0].columns[0].position").value(1))
                .andExpect(jsonPath("$.data[0].columns[0].primaryKey").value(true));
    }

    @Test
    void getReturns400WhenDatabaseNotPresent() throws Exception {
        mvc.perform(get("/api/tables/metadata"))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentType(APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.detail").value(startsWith("Required String parameter 'databaseName' is not present")));
    }

    @Test
    void getReturns404WhenDatabaseNotFound() throws Exception {
        mvc.perform(get("/api/tables/metadata")
                .param("databaseName", "oops"))
                .andExpect(status().isNotFound())
                .andExpect(content().contentType(APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.detail").value(startsWith("Database with name [oops] not found")));
    }

    @Test
    void getReturns404WhenTableNotFound() throws Exception {
        mvc.perform(get("/api/tables/metadata")
                .param("databaseName", "pagila")
                .param("tableName", "oops"))
                .andExpect(status().isNotFound())
                .andExpect(content().contentType(APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.detail").value(startsWith("Table [oops] not found in database [pagila]")));
    }

}
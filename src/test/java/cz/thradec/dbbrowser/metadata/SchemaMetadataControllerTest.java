package cz.thradec.dbbrowser.metadata;

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

class SchemaMetadataControllerTest extends AbstractTest {

    @Autowired
    private MockMvc mvc;

    @Test
    void getAll() throws Exception {
        mvc.perform(get("/api/schemas/metadata")
                .param("databaseName", "pagila"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(APPLICATION_JSON))
                .andExpect(jsonPath("$.data", hasSize(6)))
                .andExpect(jsonPath("$.data[5].name").value("public"));
    }

    @Test
    void getOne() throws Exception {
        mvc.perform(get("/api/schemas/metadata")
                .param("databaseName", "pagila")
                .param("schemaName", "public"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(APPLICATION_JSON))
                .andExpect(jsonPath("$.data[0].name").value("public"))
                .andExpect(jsonPath("$.data[0].tables[0]").value("actor"));
    }

    @Test
    void getReturns400WhenDatabaseNotPresent() throws Exception {
        mvc.perform(get("/api/schemas/metadata"))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentType(APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.detail").value(startsWith("Required String parameter 'databaseName' is not present")));
    }

    @Test
    void getReturns404WhenDatabaseNotFound() throws Exception {
        mvc.perform(get("/api/schemas/metadata")
                .param("databaseName", "oops"))
                .andExpect(status().isNotFound())
                .andExpect(content().contentType(APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.detail").value(startsWith("Database with name [oops] not found")));
    }

    @Test
    void getReturns404WhenSchemaNotFound() throws Exception {
        mvc.perform(get("/api/schemas/metadata")
                .param("databaseName", "pagila")
                .param("schemaName", "oops"))
                .andExpect(status().isNotFound())
                .andExpect(content().contentType(APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.detail").value(startsWith("Schema [oops] not found in database [pagila]")));
    }

}
package cz.thradec.dbbrowser.database;

import com.fasterxml.jackson.databind.ObjectMapper;
import cz.thradec.dbbrowser.AbstractTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;

import static java.util.Map.entry;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.http.MediaType.APPLICATION_PROBLEM_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class DatabaseControllerTest extends AbstractTest {

    @Autowired
    private MockMvc mvc;
    @Autowired
    private ObjectMapper mapper;

    @Test
    void getAll() throws Exception {
        mvc.perform(get("/api/databases"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(APPLICATION_JSON))
                .andExpect(jsonPath("$.data", hasSize(2)))
                .andExpect(jsonPath("$.data[0].name").value("pagila"))
                .andExpect(jsonPath("$.data[0].url").isString())
                .andExpect(jsonPath("$.data[0].username").isString())
                .andExpect(jsonPath("$.data[0].password").doesNotExist());
    }

    @Test
    void getByName() throws Exception {
        mvc.perform(get("/api/databases/{name}", "sakila"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(APPLICATION_JSON))
                .andExpect(jsonPath("$.data.name").value("sakila"))
                .andExpect(jsonPath("$.data.url").value(startsWith("jdbc:tc:mysql")))
                .andExpect(jsonPath("$.data.username").value("test"))
                .andExpect(jsonPath("$.data.password").doesNotExist());
    }

    @Test
    void getByName404() throws Exception {
        mvc.perform(get("/api/databases/{name}", "oops"))
                .andExpect(status().isNotFound())
                .andExpect(content().contentType(APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.detail").value(startsWith("Database with name [oops] not found.")));
    }

    @Test
    void save() throws Exception {
        var database = Map.ofEntries(
                entry("name", "test"),
                entry("url", "jdbc:h2:mem:test"),
                entry("username", "test"),
                entry("password", "123456"));

        mvc.perform(post("/api/databases")
                .contentType(APPLICATION_JSON)
                .content(mapper.writeValueAsString(database)))
                .andExpect(status().isOk());
    }

    @Test
    void save400() throws Exception {
        mvc.perform(post("/api/databases")
                .contentType(APPLICATION_JSON)
                .content("{}"))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentType(APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.detail").value(startsWith("Request is not valid")));
    }

    @Test
    void deleteAll() throws Exception {
        mvc.perform(delete("/api/databases/{name}", "pagila"))
                .andExpect(status().isOk());
        mvc.perform(delete("/api/databases/{name}", "sakila"))
                .andExpect(status().isOk());
        mvc.perform(get("/api/databases"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data").isEmpty());
    }

    @Test
    void delete404() throws Exception {
        mvc.perform(delete("/api/databases/{name}", "oops"))
                .andExpect(status().isNotFound())
                .andExpect(content().contentType(APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.detail").value("Database with name [oops] not found."));
    }

}
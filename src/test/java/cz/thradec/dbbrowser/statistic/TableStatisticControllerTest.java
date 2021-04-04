package cz.thradec.dbbrowser.statistic;

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

class TableStatisticControllerTest extends AbstractTest {

    @Autowired
    private MockMvc mvc;

    @Test
    void getStatistics() throws Exception {
        mvc.perform(get("/api/tables/statistics")
                .param("databaseName", "pagila")
                .param("tableName", "actor"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(APPLICATION_JSON))
                .andExpect(jsonPath("$.data", hasSize(1)))
                .andExpect(jsonPath("$.data[0].name").value("actor"))
                .andExpect(jsonPath("$.data[0].numberOfRows").value(200))
                .andExpect(jsonPath("$.data[0].columns", hasSize(4)))
                .andExpect(jsonPath("$.data[0].columns[1].name").value("first_name"))
                .andExpect(jsonPath("$.data[0].columns[1].min").value("ADAM"))
                .andExpect(jsonPath("$.data[0].columns[1].max").value("ZERO"))
                .andExpect(jsonPath("$.data[0].columns[1].max").value("ZERO"));
    }

    @Test
    void getReturns400WhenDatabaseNotPresent() throws Exception {
        mvc.perform(get("/api/tables/statistics"))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentType(APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.detail").value(startsWith("Required String parameter 'databaseName' is not present")));
    }

    @Test
    void getReturns404WhenTableNotFound() throws Exception {
        mvc.perform(get("/api/tables/statistics")
                .param("databaseName", "pagila")
                .param("tableName", "oops"))
                .andExpect(status().isNotFound())
                .andExpect(content().contentType(APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.detail").value(startsWith("Table [oops] not found in database [pagila]")));
    }

}
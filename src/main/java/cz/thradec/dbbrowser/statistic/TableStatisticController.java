package cz.thradec.dbbrowser.statistic;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

import static cz.thradec.dbbrowser.Response.Data;
import static cz.thradec.dbbrowser.Response.ok;

@Tag(name = "tables")
@RestController
@RequestMapping("/api/tables/statistics")
@RequiredArgsConstructor
class TableStatisticController {

    private final TableStatisticRepository tableStatisticRepository;

    @GetMapping
    @Operation(summary = "Get tables statistics (experimental)")
    Data<List<TableStatistic>> get(@RequestParam String databaseName,
                                   @RequestParam(required = false) String schemaName,
                                   @RequestParam(required = false) String tableName) {
        return ok(tableStatisticRepository.findStatistics(databaseName, schemaName, tableName));
    }

}

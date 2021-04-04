package cz.thradec.dbbrowser.metadata;

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
@RequestMapping("/api/tables/metadata")
@RequiredArgsConstructor
class TableMetadataController {

    private final TableMetadataRepository tableMetadataRepository;

    @GetMapping
    @Operation(summary = "Get tables metadata")
    Data<List<TableMetadata>> get(@RequestParam String databaseName,
                                  @RequestParam(required = false) String schemaName,
                                  @RequestParam(required = false) String tableName) {
        return ok(tableMetadataRepository.findTablesMetadata(databaseName, schemaName, tableName));
    }

}

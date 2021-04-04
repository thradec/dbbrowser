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

@Tag(name = "schemas")
@RestController
@RequestMapping("/api/schemas/metadata")
@RequiredArgsConstructor
class SchemaMetadataController {

    private final SchemaMetadataRepository schemaMetadataRepository;

    @GetMapping
    @Operation(summary = "Get schemas metadata")
    Data<List<SchemaMetadata>> get(@RequestParam String databaseName,
                                   @RequestParam(required = false) String schemaName) {
        return ok(schemaMetadataRepository.findSchemasMetadata(databaseName, schemaName));
    }

}

package cz.thradec.dbbrowser.preview;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static cz.thradec.dbbrowser.Response.Data;
import static cz.thradec.dbbrowser.Response.ok;

@Tag(name = "tables")
@RestController
@RequestMapping("/api/tables/preview")
@RequiredArgsConstructor
class PreviewController {

    private final PreviewRepository previewRepository;

    @GetMapping
    @Operation(summary = "Get preview of table data")
    Data<Preview> get(@RequestParam String databaseName,
                      @RequestParam(required = false) String schemaName,
                      @RequestParam String tableName) {
        return ok(previewRepository.findPreview(databaseName, schemaName, tableName));
    }

}

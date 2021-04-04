package cz.thradec.dbbrowser.database;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

import static cz.thradec.dbbrowser.Response.Data;
import static cz.thradec.dbbrowser.Response.ok;
import static org.springframework.web.bind.annotation.RequestMethod.POST;
import static org.springframework.web.bind.annotation.RequestMethod.PUT;

@Tag(name = "databases")
@RestController
@RequestMapping("/api/databases")
@RequiredArgsConstructor
class DatabaseController {

    private final DatabaseRepository databaseRepository;

    @GetMapping
    @Operation(summary = "Get list of all databases")
    Data<List<Database>> get() {
        return ok(databaseRepository.findAll());
    }

    @GetMapping("/{databaseName}")
    @Operation(summary = "Get database by name")
    Data<Database> get(@PathVariable String databaseName) {
        return ok(databaseRepository.findByName(databaseName));
    }

    @RequestMapping(method = {POST, PUT})
    @Operation(summary = "Create new or update existing database")
    void save(@Valid @RequestBody Database database) {
        databaseRepository.save(database);
    }

    @DeleteMapping("/{databaseName}")
    @Operation(summary = "Delete database by name")
    void delete(@PathVariable String databaseName) {
        databaseRepository.delete(databaseName);
    }

}
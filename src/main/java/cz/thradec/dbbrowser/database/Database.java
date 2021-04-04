package cz.thradec.dbbrowser.database;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import static com.fasterxml.jackson.annotation.JsonProperty.Access.WRITE_ONLY;

@Getter
@Builder(toBuilder = true)
@EqualsAndHashCode
@NoArgsConstructor
@AllArgsConstructor
class Database {

    @NotNull
    @Size(min = 1, max = 100)
    private String name;

    @NotNull
    @Size(min = 1, max = 1000)
    private String url;

    @NotNull
    @Size(min = 1, max = 100)
    private String username;

    @NotNull
    @Size(min = 1, max = 100)
    @JsonProperty(access = WRITE_ONLY)
    private String password;

}
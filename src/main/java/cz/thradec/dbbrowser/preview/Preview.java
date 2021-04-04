package cz.thradec.dbbrowser.preview;

import com.fasterxml.jackson.annotation.JsonRawValue;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
class Preview {

    private final String table;

    private final List<String> columns;

    @JsonRawValue
    private final String rows;

}
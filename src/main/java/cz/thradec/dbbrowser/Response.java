package cz.thradec.dbbrowser;

import lombok.Builder;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static org.springframework.http.MediaType.APPLICATION_PROBLEM_JSON;

public class Response {

    @Getter
    @Builder
    @RequiredArgsConstructor
    public static class Data<T> {
        private final T data;
    }

    @Getter
    @Builder
    public static class Problem {
        private final int status;
        private final String title;
        private final String detail;
    }

    public static <T> Data<T> ok(T data) {
        return new Data<>(data);
    }

    public static ResponseEntity<Problem> problem(HttpStatus status, String message) {
        var problem = Problem.builder()
                .status(status.value())
                .title(status.getReasonPhrase())
                .detail(message)
                .build();

        return ResponseEntity.status(status)
                .contentType(APPLICATION_PROBLEM_JSON)
                .body(problem);
    }

}

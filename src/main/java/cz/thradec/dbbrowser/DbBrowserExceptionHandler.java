package cz.thradec.dbbrowser;

import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.dao.DataRetrievalFailureException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.util.stream.Collectors;

import static cz.thradec.dbbrowser.Response.Problem;
import static cz.thradec.dbbrowser.Response.problem;
import static org.springframework.http.HttpStatus.*;

@Slf4j
@RestControllerAdvice
class DbBrowserExceptionHandler extends ResponseEntityExceptionHandler {

    @ExceptionHandler(DataRetrievalFailureException.class)
    ResponseEntity<Problem> handle(DataRetrievalFailureException e) {
        return problem(NOT_FOUND, e.getMessage());
    }

    @ExceptionHandler(DataAccessResourceFailureException.class)
    ResponseEntity<Problem> handle(DataAccessResourceFailureException e) {
        return problem(BAD_REQUEST, e.getMessage());
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<Problem> handle(Exception e) {
        log.error("Unhandled exception", e);
        return problem(INTERNAL_SERVER_ERROR, e.getMessage());
    }

    @Override
    protected ResponseEntity handleMethodArgumentNotValid(MethodArgumentNotValidException e, HttpHeaders headers, HttpStatus status, WebRequest request) {
        var errors = e.getBindingResult().getAllErrors()
                .stream()
                .map(error -> {
                    if (error instanceof FieldError) {
                        return ((FieldError) error).getField() + " " + error.getDefaultMessage();
                    } else {
                        return error.getDefaultMessage();
                    }
                })
                .collect(Collectors.joining(", "));
        return problem(BAD_REQUEST, "Request is not valid: " + errors);
    }

    @Override
    protected ResponseEntity handleExceptionInternal(Exception e, Object body, HttpHeaders headers, HttpStatus status, WebRequest request) {
        return problem(status, e.getMessage());
    }

}
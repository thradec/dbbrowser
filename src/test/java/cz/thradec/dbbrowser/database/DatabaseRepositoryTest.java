package cz.thradec.dbbrowser.database;

import cz.thradec.dbbrowser.AbstractTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class DatabaseRepositoryTest extends AbstractTest {

    @Autowired
    private DatabaseRepository databaseRepository;

    @Test
    void findAll() {
        var databases = databaseRepository.findAll();
        assertThat(databases).hasSize(2);
        assertThat(databases.get(0).getName()).isEqualTo("pagila");
        assertThat(databases.get(1).getName()).isEqualTo("sakila");
    }

    @Test
    void findByName() {
        var database = databaseRepository.findByName("pagila");
        assertThat(database.getName()).isEqualTo("pagila");
        assertThat(database.getUrl()).startsWith("jdbc:tc:postgresql");
        assertThat(database.getUsername()).isEqualTo("test");
        assertThat(database.getPassword()).isNotEmpty();
    }

    @Test
    void findByNameThrowsNotFoundException() {
        assertThatThrownBy(() -> databaseRepository.findByName(null))
                .isInstanceOf(DatabaseNotFoundException.class);
        assertThatThrownBy(() -> databaseRepository.findByName("oops"))
                .isInstanceOf(DatabaseNotFoundException.class);
    }

    @Test
    void saveNew() {
        var database = Database.builder()
                .name("h2")
                .url("jdbc:h2:mem:test")
                .username("test")
                .password("123456")
                .build();

        databaseRepository.save(database);

        database = databaseRepository.findByName("h2");
        assertThat(database).isNotNull();
    }

    @Test
    void saveExisting() {
        var database = databaseRepository.findByName("pagila");

        databaseRepository.save(database.toBuilder()
                .url("jdbc:h2:mem:test")
                .password("123456")
                .build());

        database = databaseRepository.findByName("pagila");
        assertThat(database.getUrl()).startsWith("jdbc:h2");
        assertThat(database.getPassword()).isEqualTo("123456");
    }

    @Test
    void saveThrowsDataIntegrityViolationException() {
        var database = databaseRepository.findByName("pagila")
                .toBuilder()
                .password(null)
                .build();
        assertThatThrownBy(() -> databaseRepository.save(database))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void delete() {
        databaseRepository.delete("pagila");
        databaseRepository.delete("sakila");
        assertThat(databaseRepository.findAll()).isEmpty();
    }

    @Test
    void deleteThrowsNotFoundException() {
        assertThatThrownBy(() -> databaseRepository.delete(null))
                .isInstanceOf(DatabaseNotFoundException.class);
        assertThatThrownBy(() -> databaseRepository.delete("oops"))
                .isInstanceOf(DatabaseNotFoundException.class);
    }

}
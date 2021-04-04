package cz.thradec.dbbrowser.database;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jooq.meta.Databases;
import org.jooq.meta.jaxb.CatalogMappingType;
import org.jooq.meta.jaxb.SchemaMappingType;
import org.springframework.boot.autoconfigure.jooq.JooqProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.jdbc.core.ConnectionCallback;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.io.Closeable;
import java.io.IOException;
import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import static java.time.LocalDateTime.now;

@Slf4j
@Component
@RequiredArgsConstructor
public class DatabaseConnector {

    private static final int DATA_SOURCE_USAGE_THRESHOLD_IN_MINUTES = 10;

    private final Map<Database, DataSourceHolder> dataSourceMap = new ConcurrentHashMap<>();

    private final DatabaseRepository databaseRepository;

    public <T> T execute(String databaseName, Callback<T> callback) {
        var database = databaseRepository.findByName(databaseName);
        var dataSourceHolder = dataSourceMap.computeIfAbsent(database, this::buildDataSource);

        dataSourceHolder.validate();
        dataSourceHolder.updateLastUsage();

        return dataSourceHolder.getJdbcTemplate().execute((ConnectionCallback<T>) con -> {
            var jooq = buildJooqDatabase(dataSourceHolder.getDataSource(), con);
            return callback.execute(jooq);
        });
    }

    private DataSourceHolder buildDataSource(Database database) {
        var dataSource = DataSourceBuilder.create()
                .url(database.getUrl())
                .username(database.getUsername())
                .password(database.getPassword())
                .build();
        return new DataSourceHolder(database, dataSource);
    }

    private org.jooq.meta.Database buildJooqDatabase(DataSource dataSource, Connection con) {
        var sqlDialect = new JooqProperties().determineSqlDialect(dataSource);

        var catalogMappingType = new CatalogMappingType();
        catalogMappingType.setSchemata(List.of(new SchemaMappingType()));

        var jooq = Databases.database(sqlDialect);
        jooq.setConnection(con);
        jooq.setConfiguredCatalogs(List.of(catalogMappingType));
        return jooq;
    }

    @Scheduled(fixedRateString = "PT10M")
    private void cleanup() {
        dataSourceMap.entrySet()
                .stream()
                .filter(this::isUnused)
                .forEach(this::destroy);
    }

    private boolean isUnused(Map.Entry<Database, DataSourceHolder> entry) {
        return entry.getValue().getLastUsage().isBefore(now().minusMinutes(DATA_SOURCE_USAGE_THRESHOLD_IN_MINUTES));
    }

    private void destroy(Map.Entry<Database, DataSourceHolder> entry) {
        log.info("Closing data source for database [{}]", entry.getKey().getName());
        var dataSourceHolder = dataSourceMap.remove(entry.getKey());
        var dataSource = dataSourceHolder.getDataSource();
        if (dataSource instanceof Closeable) {
            try {
                ((Closeable) dataSource).close();
            } catch (IOException e) {
                log.warn("Unable to close data source", e);
            }
        }
    }

    @FunctionalInterface
    public interface Callback<T> {

        T execute(org.jooq.meta.Database database);

    }

    @Getter
    private static class DataSourceHolder {

        private final Database database;
        private final DataSource dataSource;
        private final JdbcTemplate jdbcTemplate;
        private LocalDateTime lastUsage;

        DataSourceHolder(Database database, DataSource dataSource) {
            this.database = database;
            this.dataSource = dataSource;
            this.jdbcTemplate = new JdbcTemplate(dataSource);
            this.lastUsage = now();
        }

        void updateLastUsage() {
            lastUsage = now();
        }

        void validate() {
            try {
                jdbcTemplate.execute((ConnectionCallback<Object>) con -> con.isValid(1));
            } catch (RuntimeException e) {
                throw new DatabaseNotValidException(database, e);
            }
        }

    }

}
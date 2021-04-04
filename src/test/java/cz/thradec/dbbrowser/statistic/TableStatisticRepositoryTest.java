package cz.thradec.dbbrowser.statistic;

import cz.thradec.dbbrowser.AbstractTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataRetrievalFailureException;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class TableStatisticRepositoryTest extends AbstractTest {

    @Autowired
    private TableStatisticRepository tableStatisticRepository;

    @Test
    void findStatisticsForAllTables() {
        var result = tableStatisticRepository.findStatistics("pagila", "public", null);
        assertThat(result).hasSize(21);
        var actorStat = result.get(0);
        assertThat(actorStat.getName()).isEqualTo("actor");
        assertThat(actorStat.getQualifiedName()).isEqualTo("public.actor");
        assertThat(actorStat.getNumberOfRows()).isEqualTo(200);
        assertThat(actorStat.getNumberOfColumns()).isEqualTo(4);
        assertThat(actorStat.getColumns()).isNull();
    }

    @Test
    void findStatisticsForOneTable() {
        var result = tableStatisticRepository.findStatistics("pagila", null, "film");
        assertThat(result).hasSize(1);
        var filmStat = result.get(0);
        assertThat(filmStat.getName()).isEqualTo("film");
        assertThat(filmStat.getQualifiedName()).isEqualTo("public.film");
        assertThat(filmStat.getNumberOfRows()).isEqualTo(500);
        assertThat(filmStat.getNumberOfColumns()).isEqualTo(14);
        assertThat(filmStat.getColumns()).hasSize(14);
        var rentalDurationStat = filmStat.getColumns().get(6);
        assertThat(rentalDurationStat.getName()).isEqualTo("rental_duration");
        assertThat(rentalDurationStat.getMin()).isEqualTo(3);
        assertThat(rentalDurationStat.getMax()).isEqualTo(7);
        assertThat(((BigDecimal) rentalDurationStat.getAvg()).setScale(3)).isEqualByComparingTo("5.032");
        assertThat(((BigDecimal) rentalDurationStat.getMedian())).isEqualByComparingTo("5");
    }

    @Test
    void findStatisticsThrowsRetrievalException() {
        assertThatThrownBy(() -> tableStatisticRepository.findStatistics("pagila", null, "oops"))
                .isInstanceOf(DataRetrievalFailureException.class);
        assertThatThrownBy(() -> tableStatisticRepository.findStatistics("pagila", "oops", null))
                .isInstanceOf(DataRetrievalFailureException.class);
    }

}
package cz.thradec.dbbrowser.statistic;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
class TableStatistic {

    private final String name;
    private final String qualifiedName;
    private final int numberOfRows;
    private final int numberOfColumns;
    private final List<ColumnStatistic> columns;

    @Getter
    @Builder
    static class ColumnStatistic {
        private final String name;
        private final String qualifiedName;
        private final Object min;
        private final Object max;
        private final Object avg;
        private final Object median;
    }

}

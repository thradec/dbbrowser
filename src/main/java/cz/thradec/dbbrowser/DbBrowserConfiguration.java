package cz.thradec.dbbrowser;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Configuration
@EnableScheduling
@EnableTransactionManagement(proxyTargetClass = true)
class DbBrowserConfiguration {

    @Bean
    OpenAPI openAPI() {
        return new OpenAPI().info(new Info()
                .title("DBBrowser API")
                .description("Simple API for browsing database structures")
                .version("v1")
        );
    }

}

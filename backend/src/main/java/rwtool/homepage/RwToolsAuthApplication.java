package rwtool.homepage;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories(basePackages = "rwtool.homepage.repository")
public class RwToolsAuthApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(RwToolsAuthApplication.class, args);
    }
}

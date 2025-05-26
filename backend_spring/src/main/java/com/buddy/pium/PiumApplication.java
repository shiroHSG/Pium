package com.buddy.pium;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class PiumApplication {

	public static void main(String[] args) {
		SpringApplication.run(PiumApplication.class, args);
	}

}

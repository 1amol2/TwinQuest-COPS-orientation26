package com.twinquest.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = {"com.twinquest.backend", "com.pairquest.backend"})
public class TwinquestBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(TwinquestBackendApplication.class, args);
	}

}

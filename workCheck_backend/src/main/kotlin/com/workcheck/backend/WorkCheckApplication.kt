package com.workcheck.backend

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

// Spring Boot 애플리케이션 진입점
@SpringBootApplication
class WorkCheckApplication

fun main(args: Array<String>) {
    runApplication<WorkCheckApplication>(*args)
}

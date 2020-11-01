package com.computas.devops101.notatapi

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/healthz")
class HealthController {

    @GetMapping
    fun getHealthz(): String = "Not Healthy"

}

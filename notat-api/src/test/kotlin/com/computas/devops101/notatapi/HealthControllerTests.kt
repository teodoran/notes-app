package com.computas.devops101.notatapi

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.assertTrue

class HealthControllerTests {

    @Test
    fun testResponseIsHealthyOrOk() {
        assertTrue(HealthController().getHealthz().let { it == "Ok" || it == "Healthy" }, "response must be 'Ok' or 'Healthy'")
    }
}
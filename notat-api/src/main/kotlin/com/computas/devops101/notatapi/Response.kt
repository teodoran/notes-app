package com.computas.devops101.notatapi

import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.client.HttpClientErrorException
import java.lang.RuntimeException

object Response {

    @ResponseStatus(HttpStatus.NOT_FOUND)
    class NotFound(message: String? = null): RuntimeException(message)

}
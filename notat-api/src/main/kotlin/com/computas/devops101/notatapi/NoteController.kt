package com.computas.devops101.notatapi

import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/notes")
class NoteController(private val repository: NoteRepository<String>) {

    @GetMapping
    fun getNotes(): Collection<Note> = repository.findAll().toList()

    @GetMapping("{id}")
    fun getNote(@PathVariable("id") id: String): Note = repository.findById(id) ?: throw Response.NotFound()

    @PostMapping
    fun createNote(@RequestBody text: String): Note = repository.create(text)

    @PutMapping("{id}")
    fun saveNote(@PathVariable("id") id: String, @RequestBody text: String): Note = repository.save(id, text)

    @DeleteMapping("{id}")
    fun deleteNote(@PathVariable("id") id: String): Unit = repository.deleteById(id)
}

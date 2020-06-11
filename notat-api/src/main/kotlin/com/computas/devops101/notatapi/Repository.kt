package com.computas.devops101.notatapi

import org.springframework.stereotype.Component
import java.util.*
import kotlin.collections.HashMap

interface NoteRepository<ID> {
    fun findAll(): Iterable<Note>
    fun findById(id: ID): Note?
    fun create(text: String): Note
    fun save(id: ID, text: String): Note
    fun deleteById(id: ID)
}

@Component
class InMemoryNotes : NoteRepository<String> {
    private val store = HashMap<String, Note>()

    override fun findAll(): Iterable<Note> = store.values

    override fun findById(id: String): Note? = store[id]

    override fun create(text: String): Note {
        val note = Note(id = UUID.randomUUID().toString(), text = text)
        store[note.id] = note

        return note
    }

    override fun save(id: String, text: String): Note {
        val note = store[id]?.copy(text = text) ?: Note(id = id, text = text)
        store[note.id] = note

        return note
    }

    override fun deleteById(id: String) {
        store.remove(id)
    }

}
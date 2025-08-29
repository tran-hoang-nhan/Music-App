package com.example.musicapp.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Playlist {
    private String id;
    private String name;
    private Map<String, Song> songs;
    private long createdAt;

    public Playlist() {
        // Required for Firebase
    }

    public Playlist(String id, String name, List<Song> songList) {
        this.id = id;
        this.name = name;
        this.songs = new HashMap<>();
        this.createdAt = System.currentTimeMillis();
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Map<String, Song> getSongs() { return songs; }
    public void setSongs(Map<String, Song> songs) { this.songs = songs; }

    public List<Song> getSongsList() {
        if (songs == null) return new ArrayList<>();
        return new ArrayList<>(songs.values());
    }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }
}
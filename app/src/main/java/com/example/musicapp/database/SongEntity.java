package com.example.musicapp.database;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "songs")
public class SongEntity {
    @PrimaryKey
    @NonNull
    public String id;
    @NonNull
    public String name;
    @NonNull
    public String artistName;
    public String artistId;
    public String imageUrl;
    public String audioUrl;
    public int duration;
    public long timestamp;
    public boolean isFavorite;
    public boolean isDownloaded;

    public SongEntity() {
        id = "";
        artistName = "";
        name = "";
    }

    public SongEntity(@NonNull String id, @NonNull String name, @NonNull String artistName, String artistId,
                      String imageUrl, String audioUrl, int duration) {
        this.id = id;
        this.name = name;
        this.artistName = artistName;
        this.artistId = artistId;
        this.imageUrl = imageUrl;
        this.audioUrl = audioUrl;
        this.duration = duration;
        this.timestamp = System.currentTimeMillis();
        this.isFavorite = false;
        this.isDownloaded = false;
    }
}
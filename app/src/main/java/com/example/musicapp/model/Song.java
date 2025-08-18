package com.example.musicapp.model;

import com.google.gson.annotations.SerializedName;

public class Song {
    private String id;
    private String name;

    @SerializedName("duration")
    private int duration;

    @SerializedName("artist_name")
    private String artistName;

    @SerializedName("album_name")
    private String albumName;

    @SerializedName("releasedate")
    private String releaseDate;

    @SerializedName("audio")
    private String audioUrl; // link mp3

    @SerializedName("image")
    private String imageUrl; // ảnh cover

    // --- Constructor mặc định (cần cho Gson) ---
    public Song() {
    }

    // --- Constructor đầy đủ tham số (dùng khi tạo thủ công) ---
    public Song(String id, String name, int duration, String artistName,
                String albumName, String releaseDate,
                String audioUrl, String imageUrl) {
        this.id = id;
        this.name = name;
        this.duration = duration;
        this.artistName = artistName;
        this.albumName = albumName;
        this.releaseDate = releaseDate;
        this.audioUrl = audioUrl;
        this.imageUrl = imageUrl;
    }

    // --- Getter & Setter ---
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }

    public String getArtistName() { return artistName; }
    public void setArtistName(String artistName) { this.artistName = artistName; }

    public String getAlbumName() { return albumName; }
    public void setAlbumName(String albumName) { this.albumName = albumName; }

    public String getReleaseDate() { return releaseDate; }
    public void setReleaseDate(String releaseDate) { this.releaseDate = releaseDate; }

    public String getAudioUrl() { return audioUrl; }
    public void setAudioUrl(String audioUrl) { this.audioUrl = audioUrl; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}

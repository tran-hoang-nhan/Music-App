package com.example.musicapp.model;

import com.google.gson.annotations.SerializedName;

public class Song {
    private String id;
    private String name;

    @SerializedName("duration")
    private int duration;

    @SerializedName("artist_id")
    private String artistId;
    @SerializedName("artist_name")
    private String artistName;
    private String artistImage;

    @SerializedName("album_name")
    private String albumName;

    @SerializedName("releasedate")
    private String releaseDate;

    @SerializedName("audio")
    private String audioUrl;

    @SerializedName("image")
    private String imageUrl;

    private int position; // thứ tự bài trong album

    public Song() {}

    public Song(String id, String name, int duration, String artistId, String artistName, String artistImage,
                String albumName, String releaseDate, String audioUrl, String imageUrl, int position) {
        this.id = id;
        this.name = name;
        this.duration = duration;
        this.artistId = artistId;
        this.artistName = artistName;
        this.artistImage = artistImage;
        this.albumName = albumName;
        this.releaseDate = releaseDate;
        this.audioUrl = audioUrl;
        this.imageUrl = imageUrl;
        this.position = position;
    }
    
    // Constructor for favorites/offline
    public Song(String id, String name, String artistName, String artistId, String imageUrl, String audioUrl, String duration) {
        this.id = id;
        this.name = name;
        this.artistName = artistName;
        this.artistId = artistId;
        this.imageUrl = imageUrl;
        this.audioUrl = audioUrl;
        this.duration = duration != null ? Integer.parseInt(duration) : 0;
    }

    // --- Getters & Setters ---
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }

    public String getArtistId() { return artistId; }
    public void setArtistId(String artistId) { this.artistId = artistId; }

    public String getArtistName() { return artistName; }
    public void setArtistName(String artistName) { this.artistName = artistName; }

    public String getArtistImage() { return artistImage; }
    public void setArtistImage(String artistImage) { this.artistImage = artistImage; }

    public String getAlbumName() { return albumName; }
    public void setAlbumName(String albumName) { this.albumName = albumName; }

    public String getReleaseDate() { return releaseDate; }
    public void setReleaseDate(String releaseDate) { this.releaseDate = releaseDate; }

    public String getAudioUrl() { return audioUrl; }
    public void setAudioUrl(String audioUrl) { this.audioUrl = audioUrl; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public int getPosition() { return position; }
    public void setPosition(int position) { this.position = position; }
}

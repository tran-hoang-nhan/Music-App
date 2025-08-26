package com.example.musicapp.model;

import com.google.gson.annotations.SerializedName;
import java.io.Serializable;
import java.util.List;

public class AlbumResponse {
    @SerializedName("results")
    private List<Album> albums;

    public List<Album> getAlbums() { return albums; }

    public static class Album implements Serializable {
        private String id;
        private String name;
        @SerializedName("artist_name")
        private String artistName;
        private String image;
        @SerializedName("releasedate")
        private String releaseDate;
        private String genre;
        @SerializedName("tracks")
        private List<Song> tracks;
        public List<Song> getTracks() { return tracks; }

        // các getter khác
        public String getId() { return id; }
        public String getName() { return name; }
        public String getArtistName() { return artistName; }
        public String getImage() { return image; }
        public String getReleaseDate() { return releaseDate; }
        public String getGenre() { return genre; }
    }
}

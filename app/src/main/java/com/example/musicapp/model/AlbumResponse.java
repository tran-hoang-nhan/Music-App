package com.example.musicapp.model;

import java.util.List;

public class AlbumResponse {
    private List<Album> results;

    public AlbumResponse() {}

    public List<Album> getAlbums() { return results; }

    public static class Album {
        private String name;
        private String artist_name;
        private String releasedate;
        private String image;

        public Album() {}
        public Album(String name, String artist_name, String releasedate, String image) {
            this.name = name;
            this.artist_name = artist_name;
            this.releasedate = releasedate;
            this.image = image;
        }

        // Getter
        public String getName() { return name; }
        public String getArtist_name() { return artist_name; }
        public String getReleasedate() { return releasedate; }
        public String getImage() { return image; }
    }
}

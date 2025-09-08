package com.example.musicapp.model;

import java.util.List;

public class PlaylistResponse {

    private List<Playlist> results;

    public List<Playlist> getResults() {
        return results;
    }

    // inner class Playlist
    public static class Playlist {
        private String id;
        private String name;
        private String image;
        private java.util.List<Song> tracks; // Thêm field để lưu tracks

        public String getId() { return id; }
        public String getName() { return name; }
        public String getImage() { return image; }
        public java.util.List<Song> getTracks() { return tracks; }
        
        public void setId(String id) { this.id = id; }
        public void setName(String name) { this.name = name; }
        public void setImage(String image) { this.image = image; }
        public void setTracks(java.util.List<Song> tracks) { this.tracks = tracks; }
    }
}


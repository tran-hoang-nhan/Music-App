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

        public String getId() { return id; }
        public String getName() { return name; }
        public String getImage() { return image; }
    }
}


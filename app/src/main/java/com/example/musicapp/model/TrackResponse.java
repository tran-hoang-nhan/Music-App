package com.example.musicapp.model;

import java.util.List;

public class TrackResponse {
    public List<Track> results;

    public TrackResponse() {}

    public TrackResponse(List<Track> results) { this.results = results; }

    // Trả về danh sách Track, không phải Song
    public List<Track> getTracks() {
        return results;
    }

    public static class Track {
        public String id;
        public String name;
        public String artist_name;
        public String audio;
        public String image;

        public Track() {}
        public Track(String id, String name, String artist_name, String audio, String image) {
            this.id = id;
            this.name = name;
            this.artist_name = artist_name;
            this.audio = audio;
            this.image = image;
        }
    }
}




package com.example.musicapp.model;

import com.google.gson.annotations.SerializedName;
import java.util.List;

public class ArtistResponse {
    @SerializedName("results")
    private List<Artist> artists;

    public ArtistResponse() {}

    public List<Artist> getArtists() { return artists; }

    public static class Artist {
        private String id;
        private String name;

        @SerializedName("website")
        private String website;

        @SerializedName("joindate")
        private String joinDate;

        @SerializedName("image")
        private String image;

        public Artist() {}

        // Getter
        public String getId() { return id; }
        public String getName() { return name; }
        public String getWebsite() { return website; }
        public String getJoinDate() { return joinDate; }
        public String getImage() { return image; }
    }
}

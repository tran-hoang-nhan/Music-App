package com.example.musicapp.model;

import java.util.ArrayList;
import java.util.List;

public class Genre {

    private String id;
    private String name;
    private String imageUrl;

    public Genre(String id, String name, String imageUrl) {
        this.id = id;
        this.name = name;
        this.imageUrl = imageUrl;
    }

    public String getId() { return id; }
    public String getName() { return name; }
    public String getImageUrl() { return imageUrl; }

    // Tạo danh sách genre thủ công
    public static List<Genre> getDefaultGenres() {
        List<Genre> genres = new ArrayList<>();
        genres.add(new Genre("pop", "Pop", "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4"));
        genres.add(new Genre("rap", "Rap", "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4"));
        genres.add(new Genre("rock", "Rock", "https://images.unsplash.com/photo-1507874457470-272b3c8d8ee2"));
        genres.add(new Genre("jazz", "Jazz", "https://images.unsplash.com/photo-1507874457470-272b3c8d8ee2"));
        genres.add(new Genre("rnb", "R&B", "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4"));
        genres.add(new Genre("alternative", "Alternative", "https://images.unsplash.com/photo-1497032628192-86f99bcd76bc"));
        return genres;
    }

}

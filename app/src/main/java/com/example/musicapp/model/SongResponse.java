package com.example.musicapp.model;

import com.google.gson.annotations.SerializedName;
import java.util.List;

public class SongResponse {
    @SerializedName("results")
    private List<Song> results;

    public List<Song> getResults() {
        return results;
    }

    public void setResults(List<Song> results) {
        this.results = results;
    }
}

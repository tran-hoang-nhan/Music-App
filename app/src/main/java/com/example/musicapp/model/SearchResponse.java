package com.example.musicapp.model;

import java.util.List;

public class SearchResponse<T> {
    private List<T> results;
    public List<T> getResults() { return results; }
    public void setResults(List<T> results) { this.results = results; }
}



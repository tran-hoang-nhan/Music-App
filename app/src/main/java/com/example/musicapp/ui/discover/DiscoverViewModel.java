package com.example.musicapp.ui.discover;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.example.musicapp.model.Genre;

import java.util.List;

public class DiscoverViewModel extends ViewModel {
    private final MutableLiveData<List<Genre>> genres = new MutableLiveData<>();

    public LiveData<List<Genre>> getGenres() {
        return genres;
    }
    public void fetchGenres() {
        genres.setValue(Genre.getDefaultGenres());
    }
}

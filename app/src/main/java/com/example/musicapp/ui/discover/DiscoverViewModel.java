package com.example.musicapp.ui.discover;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.example.musicapp.api.ApiService;
import com.example.musicapp.model.Genre;
import com.example.musicapp.model.Song;
import com.example.musicapp.model.SongResponse;
import com.example.musicapp.network.RetrofitClient;

import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class DiscoverViewModel extends ViewModel {
    private final MutableLiveData<List<Genre>> genres = new MutableLiveData<>();
    private final MutableLiveData<List<Song>> genreSongs = new MutableLiveData<>();
    private final MutableLiveData<Boolean> loading = new MutableLiveData<>();
    private final MutableLiveData<String> selectedGenre = new MutableLiveData<>();

    public LiveData<List<Genre>> getGenres() {
        return genres;
    }

    public LiveData<List<Song>> getGenreSongs() {
        return genreSongs;
    }

    public LiveData<Boolean> isLoading() {
        return loading;
    }

    public LiveData<String> getSelectedGenre() {
        return selectedGenre;
    }

    public void fetchGenres() {
        genres.setValue(Genre.getDefaultGenres());
    }

    public void loadSongsByGenre(String genre) {
        selectedGenre.setValue(genre);
        loading.setValue(true);

        ApiService apiService = RetrofitClient.getClient().create(ApiService.class);
        Call<SongResponse> call = apiService.getByGenre(
                ApiService.CLIENT_ID,
                "json",
                50,
                "popularity_total",
                genre
        );

        call.enqueue(new Callback<SongResponse>() {
            @Override
            public void onResponse(Call<SongResponse> call, Response<SongResponse> response) {
                loading.setValue(false);
                if (response.isSuccessful() && response.body() != null) {
                    genreSongs.setValue(response.body().getResults());
                }
            }

            @Override
            public void onFailure(Call<SongResponse> call, Throwable t) {
                loading.setValue(false);
            }
        });
    }

    public void clearGenreSongs() {
        genreSongs.setValue(null);
        selectedGenre.setValue(null);
    }
}

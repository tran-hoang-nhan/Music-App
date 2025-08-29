package com.example.musicapp.ui.discover;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.example.musicapp.api.ApiService;
import com.example.musicapp.model.Song;
import com.example.musicapp.model.SongResponse;
import com.example.musicapp.network.RetrofitClient;

import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class GenreDetailViewModel extends ViewModel {

    private final MutableLiveData<List<Song>> songs = new MutableLiveData<>();
    private final MutableLiveData<Boolean> loading = new MutableLiveData<>();

    public LiveData<List<Song>> getSongs() {
        return songs;
    }

    public LiveData<Boolean> isLoading() {
        return loading;
    }

    public void loadSongsByGenre(String genre) {
        loading.setValue(true);

        ApiService apiService = RetrofitClient.getClient().create(ApiService.class);
        Call<SongResponse> call = apiService.getByGenre(
                ApiService.CLIENT_ID,
                "json",
                50,
                "popularity_total",
                genre
        );

        call.enqueue(new Callback<>() {
            @Override
            public void onResponse(@NonNull Call<SongResponse> call, @NonNull Response<SongResponse> response) {
                loading.setValue(false);
                if (response.isSuccessful() && response.body() != null) {
                    songs.setValue(response.body().getResults());
                }
            }

            @Override
            public void onFailure(@NonNull Call<SongResponse> call, @NonNull Throwable t) {
                loading.setValue(false);
            }
        });
    }
}
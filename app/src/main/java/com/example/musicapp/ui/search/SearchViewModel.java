package com.example.musicapp.ui.search;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.example.musicapp.api.ApiService;
import com.example.musicapp.database.AppDatabase;
import com.example.musicapp.model.AlbumResponse;
import com.example.musicapp.model.Song;
import com.example.musicapp.model.SearchResponse;
import com.example.musicapp.network.RetrofitClient;
import com.example.musicapp.repository.MusicRepository;

import java.util.ArrayList;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class SearchViewModel extends ViewModel {

    private static final String CLIENT_ID = "923ff030";
    private static final String FORMAT = "json";
    private static final int LIMIT_SONGS = 20;
    private static final int LIMIT_ALBUMS = 50;

    private final ApiService apiService = RetrofitClient.getClient().create(ApiService.class);
    private MusicRepository repository;

    private final MutableLiveData<List<Song>> songs = new MutableLiveData<>();
    private final MutableLiveData<List<AlbumResponse.Album>> albums = new MutableLiveData<>();
    private final MutableLiveData<Boolean> isLoading = new MutableLiveData<>(false);

    public LiveData<List<Song>> getSongs() { return songs; }
    public LiveData<List<AlbumResponse.Album>> getAlbums() { return albums; }
    public LiveData<Boolean> isLoading() { return isLoading; }

    // Initialize repository
    public void initRepository(AppDatabase database) {
        this.repository = MusicRepository.getInstance(database, apiService);
    }
    
    // Search with Repository (local + API)
    public void fetchSongs(String query) {
        if (repository != null) {
            // Search in cached data first
            repository.searchSongs(query).observeForever(cachedSongs -> {
                if (cachedSongs != null && !cachedSongs.isEmpty()) {
                    songs.setValue(cachedSongs);
                }
            });
        }
        
        // Then search API
        isLoading.setValue(true);
        apiService.searchTracks(CLIENT_ID, FORMAT, LIMIT_SONGS, query)
                .enqueue(new Callback<>() {
                    @Override
                    public void onResponse(@NonNull Call<SearchResponse<Song>> call,
                                           @NonNull Response<SearchResponse<Song>> response) {
                        if (response.isSuccessful() && response.body() != null) {
                            List<Song> apiResults = response.body().getResults();
                            songs.setValue(apiResults);
                            
                            // Cache search results
                            if (repository != null && apiResults != null) {
                                for (Song song : apiResults) {
                                    repository.insertSong(song);
                                }
                            }
                            
                            Log.d("SearchViewModel", "Songs fetched: " + apiResults.size());
                        }
                        isLoading.setValue(false);
                    }

                    @Override
                    public void onFailure(@NonNull Call<SearchResponse<Song>> call, @NonNull Throwable t) {
                        Log.e("SearchViewModel", "Failed to fetch songs", t);
                        isLoading.setValue(false);
                    }
                });
    }

    // Tách riêng fetch album
    public void fetchAlbums(String query) {
        albums.setValue(new ArrayList<>());
        apiService.searchAlbums(CLIENT_ID, FORMAT, LIMIT_ALBUMS, query)
                .enqueue(new Callback<>() {
                    @Override
                    public void onResponse(@NonNull Call<SearchResponse<AlbumResponse.Album>> call,
                                           @NonNull Response<SearchResponse<AlbumResponse.Album>> response) {
                        if (response.isSuccessful() && response.body() != null) {
                            albums.setValue(response.body().getResults());
                            Log.d("SearchViewModel", "Albums fetched: " + response.body().getResults().size());
                        } else {
                            albums.setValue(new ArrayList<>()); // reset nếu trống
                        }
                    }

                    @Override
                    public void onFailure(@NonNull Call<SearchResponse<AlbumResponse.Album>> call, @NonNull Throwable t) {
                        Log.e("SearchViewModel", "Failed to fetch albums", t);
                        albums.setValue(new ArrayList<>()); // reset nếu fail
                    }
                });
    }


    // Gọi cùng lúc
    public void searchAll(String query) {
        if (query == null || query.isEmpty()) return;
        fetchSongs(query);
        fetchAlbums(query);
    }
}

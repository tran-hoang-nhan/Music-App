package com.example.musicapp.ui.dashboard;

import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.example.musicapp.api.ApiService;
import com.example.musicapp.database.AppDatabase;
import com.example.musicapp.model.ArtistResponse;
import com.example.musicapp.model.PlaylistResponse;
import com.example.musicapp.model.Song;
import com.example.musicapp.model.SongResponse;
import com.example.musicapp.network.RetrofitClient;
import com.example.musicapp.repository.MusicRepository;

import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class DashboardViewModel extends ViewModel {

    private static final String CLIENT_ID = "923ff030";
    private static final String FORMAT = "json";
    private static final int LIMIT = 20;


    private final ApiService apiService = RetrofitClient.getClient().create(ApiService.class);
    private MusicRepository repository;
    private final MutableLiveData<List<Song>> topHits = new MutableLiveData<>();
    private final MutableLiveData<List<Song>> randomTracks = new MutableLiveData<>();
    private final MutableLiveData<List<ArtistResponse.Artist>> topArtists = new MutableLiveData<>();
    private final MutableLiveData<List<PlaylistResponse.Playlist>> playlists = new MutableLiveData<>();
    private final MutableLiveData<Boolean> isLoading = new MutableLiveData<>(false);
    private final MutableLiveData<String> errorMessage = new MutableLiveData<>();
    
    private int loadingCounter = 0;


    public LiveData<List<Song>> getTopHits() { return topHits; }
    public LiveData<List<Song>> getRandomTracks() { return randomTracks; }
    public LiveData<List<ArtistResponse.Artist>> getTopArtists() { return topArtists; }
    public LiveData<List<PlaylistResponse.Playlist>> getPlaylists() { return playlists; }
    public LiveData<Boolean> isLoading() { return isLoading; }
    public LiveData<String> getErrorMessage() { return errorMessage; }
    
    private void startLoading() {
        loadingCounter++;
        isLoading.setValue(true);
    }
    
    private void stopLoading() {
        loadingCounter--;
        if (loadingCounter <= 0) {
            loadingCounter = 0;
            isLoading.setValue(false);
        }
    }


    public void fetchTopHits() {
        if (repository == null) {
            // Fallback to direct API call if repository not initialized
            fetchTopHitsDirectly();
            return;
        }
        
        startLoading();
        // Use Repository pattern - gets cached data + fetches fresh data
        repository.getSongs().observeForever(songs -> {
            stopLoading();
            if (songs != null) {
                topHits.setValue(songs);
            }
        });
    }
    
    private void fetchTopHitsDirectly() {
        startLoading();
        apiService.getTopHits(CLIENT_ID, FORMAT, LIMIT, "popularity_total")
                .enqueue(new Callback<>() {
                    @Override
                    public void onResponse(@NonNull Call<SongResponse> call, @NonNull Response<SongResponse> response) {
                        stopLoading();
                        if (response.isSuccessful() && response.body() != null) {
                            topHits.setValue(response.body().getResults());
                        } else {
                            errorMessage.setValue("Không thể tải top hits");
                        }
                    }

                    @Override
                    public void onFailure(@NonNull Call<SongResponse> call, @NonNull Throwable t) {
                        stopLoading();
                        errorMessage.setValue("Lỗi kết nối: " + t.getMessage());
                    }
                });
    }

    public void fetchRandomTracks() {
        startLoading();
        apiService.getRandomTracks(CLIENT_ID, FORMAT, LIMIT, "relevance")
                .enqueue(new Callback<>() {
                    @Override
                    public void onResponse(@NonNull Call<SongResponse> call, @NonNull Response<SongResponse> response) {
                        stopLoading();
                        if (response.isSuccessful() && response.body() != null) {
                            randomTracks.setValue(response.body().getResults());
                        } else {
                            errorMessage.setValue("Không thể tải gợi ý");
                        }
                    }

                    @Override
                    public void onFailure(@NonNull Call<SongResponse> call, @NonNull Throwable t) {
                        stopLoading();
                        errorMessage.setValue("Lỗi kết nối: " + t.getMessage());
                    }
                });
    }

    public void fetchPlaylists() {
        startLoading();
        // Lấy albums nổi bật thay vì playlists
        apiService.getNewAlbums(CLIENT_ID, FORMAT, 8, "popularity_total")
                .enqueue(new Callback<>() {
                    @Override
                    public void onResponse(@NonNull Call<com.example.musicapp.model.AlbumResponse> call, @NonNull Response<com.example.musicapp.model.AlbumResponse> response) {
                        stopLoading();
                        if (response.isSuccessful() && response.body() != null) {
                            // Convert albums to playlists format
                            java.util.List<PlaylistResponse.Playlist> albumPlaylists = new java.util.ArrayList<>();
                            for (com.example.musicapp.model.AlbumResponse.Album album : response.body().getAlbums()) {
                                PlaylistResponse.Playlist playlist = new PlaylistResponse.Playlist();
                                playlist.setId(album.getId());
                                playlist.setName(album.getName());
                                playlist.setImage(album.getImage());
                                albumPlaylists.add(playlist);
                            }
                            playlists.setValue(albumPlaylists);
                        } else {
                            errorMessage.setValue("Không thể tải albums");
                        }
                    }

                    @Override
                    public void onFailure(@NonNull Call<com.example.musicapp.model.AlbumResponse> call, @NonNull Throwable t) {
                        stopLoading();
                        errorMessage.setValue("Lỗi kết nối: " + t.getMessage());
                    }
                });
    }


    public void fetchTopArtists() {
        startLoading();
        apiService.getTopArtists(CLIENT_ID, FORMAT, LIMIT, "popularity_total")
                .enqueue(new Callback<>() {
                    @Override
                    public void onResponse(@NonNull Call<ArtistResponse> call, @NonNull Response<ArtistResponse> response) {
                        stopLoading();
                        if (response.isSuccessful() && response.body() != null) {
                            topArtists.setValue(response.body().getArtists());
                        } else {
                            errorMessage.setValue("Không thể tải nghệ sĩ");
                        }
                    }
                    @Override
                    public void onFailure(@NonNull Call<ArtistResponse> call, @NonNull Throwable t) {
                        stopLoading();
                        errorMessage.setValue("Lỗi kết nối: " + t.getMessage());
                    }
                });
    }


    // Initialize repository (call from Fragment)
    public void initRepository(AppDatabase database) {
        this.repository = MusicRepository.getInstance(database, apiService);
    }
    
    // Gọi tất cả API cùng lúc
    public void fetchAll() {
        errorMessage.setValue(null);
        fetchTopHits();
        fetchRandomTracks();
        fetchPlaylists();
        fetchTopArtists();
    }
}

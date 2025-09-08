package com.example.musicapp.repository;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MediatorLiveData;

import com.example.musicapp.api.ApiService;
import com.example.musicapp.database.AppDatabase;
import com.example.musicapp.database.SongDao;
import com.example.musicapp.database.SongEntity;
import com.example.musicapp.model.Song;
import com.example.musicapp.utils.DataConverter;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MusicRepository {
    
    private static MusicRepository instance;
    private final SongDao songDao;
    private final ApiService apiService;
    private final ExecutorService executor;
    
    private MusicRepository(AppDatabase database, ApiService apiService) {
        this.songDao = database.songDao();
        this.apiService = apiService;
        this.executor = Executors.newFixedThreadPool(4);
    }
    
    public static synchronized MusicRepository getInstance(AppDatabase database, ApiService apiService) {
        if (instance == null) {
            instance = new MusicRepository(database, apiService);
        }
        return instance;
    }
    
    // Get songs with cache-first approach (still need internet to play)
    public LiveData<List<Song>> getSongs() {
        MediatorLiveData<List<Song>> result = new MediatorLiveData<>();
        
        // Show cached metadata first for faster loading
        LiveData<List<SongEntity>> cachedSongs = songDao.getAllSongs();
        result.addSource(cachedSongs, entities -> result.setValue(convertToSongs(entities != null ? entities : new ArrayList<>())));
        
        // Fetch fresh metadata from API and cache
        fetchAndCacheSongs();
        
        return result;
    }
    
    // Manual refresh from API
    public void refreshSongs() {
        fetchAndCacheSongs();
    }
    
    public LiveData<List<Song>> getFavoriteSongs() {
        MediatorLiveData<List<Song>> result = new MediatorLiveData<>();
        LiveData<List<SongEntity>> favoriteEntities = songDao.getFavoriteSongs();
        
        result.addSource(favoriteEntities, entities -> {
            if (entities != null) {
                result.setValue(convertToSongs(entities));
            }
        });
        
        return result;
    }
    
    public LiveData<List<Song>> getRecentSongs() {
        MediatorLiveData<List<Song>> result = new MediatorLiveData<>();
        LiveData<List<SongEntity>> recentEntities = songDao.getRecentSongs();
        
        result.addSource(recentEntities, entities -> {
            if (entities != null) {
                result.setValue(convertToSongs(entities));
            }
        });
        
        return result;
    }
    
    public LiveData<List<Song>> searchSongs(String query) {
        MediatorLiveData<List<Song>> result = new MediatorLiveData<>();
        LiveData<List<SongEntity>> searchResults = songDao.searchSongs("%" + query + "%");
        
        result.addSource(searchResults, entities -> {
            if (entities != null) {
                result.setValue(convertToSongs(entities));
            }
        });
        
        return result;
    }
    
    public void updateFavoriteStatus(String songId, boolean isFavorite) {
        if (songId == null || songId.trim().isEmpty()) {
            android.util.Log.w("Repository", "Invalid songId for favorite update");
            return;
        }
        executor.execute(() -> {
            try {
                songDao.updateFavoriteStatus(songId, isFavorite);
            } catch (Exception e) {
                android.util.Log.e("Repository", "Failed to update favorite status", e);
            }
        });
    }
    
    // OFFLINE MODE: Only downloaded songs (works without internet)
    public LiveData<List<Song>> getOfflineSongs() {
        MediatorLiveData<List<Song>> result = new MediatorLiveData<>();
        LiveData<List<SongEntity>> downloadedEntities = songDao.getDownloadedSongs();
        
        result.addSource(downloadedEntities, entities -> {
            if (entities != null) {
                result.setValue(convertToSongs(entities));
            }
        });
        
        return result;
    }
    
    // Mark song as downloaded with local file path
    public void markSongAsDownloaded(String songId, String localFilePath) {
        executor.execute(() -> {
            SongEntity song = songDao.getSongById(songId);
            if (song != null) {
                song.audioUrl = localFilePath; // Replace with local path
                song.isDownloaded = true;
                songDao.updateSong(song);
            }
        });
    }
    
    public void updateDownloadStatus(String songId, boolean isDownloaded) {
        executor.execute(() -> songDao.updateDownloadStatus(songId, isDownloaded));
    }
    
    public void insertSong(Song song) {
        executor.execute(() -> {
            SongEntity entity = convertToEntity(song);
            songDao.insertSong(entity);
        });
    }
    
    private void fetchAndCacheSongs() {
        executor.execute(() -> {
            try {
                // Fetch song metadata from API for caching (NOT downloading audio)
                retrofit2.Call<com.example.musicapp.model.SongResponse> call = apiService.getTopHits(
                    com.example.musicapp.api.ApiService.CLIENT_ID, "json", 20, "popularity_total"
                );
                retrofit2.Response<com.example.musicapp.model.SongResponse> response = call.execute();
                
                if (response.isSuccessful() && response.body() != null) {
                    List<Song> apiSongs = response.body().getResults();
                    if (apiSongs != null && !apiSongs.isEmpty()) {
                        // Cache metadata only (for faster loading)
                        cacheSongs(apiSongs);
                        android.util.Log.d("Repository", "Cached " + apiSongs.size() + " song metadata");
                    }
                } else {
                    android.util.Log.w("Repository", "API response not successful: " + response.code());
                }
            } catch (java.net.SocketTimeoutException e) {
                android.util.Log.e("Repository", "Network timeout", e);
            } catch (java.io.IOException e) {
                android.util.Log.e("Repository", "Network error", e);
            } catch (Exception e) {
                android.util.Log.e("Repository", "Unexpected error during API call", e);
            }
        });
    }
    
    private void cacheSongs(List<Song> songs) {
        executor.execute(() -> {
            List<SongEntity> entities = new ArrayList<>();
            for (Song song : songs) {
                entities.add(convertToEntity(song));
            }
            songDao.insertSongs(entities);
        });
    }
    
    private List<Song> convertToSongs(List<SongEntity> entities) {
        return DataConverter.entitiesToSongs(entities);
    }
    
    private Song convertToSong(SongEntity entity) {
        return DataConverter.entityToSong(entity);
    }
    
    private SongEntity convertToEntity(Song song) {
        return DataConverter.songToEntity(song);
    }
}
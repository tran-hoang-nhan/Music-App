package com.example.musicapp.storage;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Environment;

import com.example.musicapp.database.AppDatabase;
import com.example.musicapp.model.Song;
import com.example.musicapp.repository.MusicRepository;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Type;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class OfflineManager {
    
    private static OfflineManager instance;
    private Context context;
    private SharedPreferences prefs;
    private Gson gson;
    private ExecutorService downloadExecutor;
    private OnDownloadListener listener;
    private MusicRepository repository;
    
    public interface OnDownloadListener {
        void onDownloadStarted(Song song);
        void onDownloadProgress(Song song, int progress);
        void onDownloadCompleted(Song song, String filePath);
        void onDownloadFailed(Song song, String error);
    }
    
    private OfflineManager(Context context) {
        this.context = context.getApplicationContext();
        this.prefs = context.getSharedPreferences("offline_prefs", Context.MODE_PRIVATE);
        this.gson = new Gson();
        this.downloadExecutor = Executors.newFixedThreadPool(2);
        
        // Initialize Repository for sync
        AppDatabase db = AppDatabase.getDatabase(context);
        com.example.musicapp.api.ApiService apiService = com.example.musicapp.network.RetrofitClient.getClient().create(com.example.musicapp.api.ApiService.class);
        this.repository = MusicRepository.getInstance(db, apiService);
    }
    
    public static synchronized OfflineManager getInstance(Context context) {
        if (instance == null) {
            instance = new OfflineManager(context);
        }
        return instance;
    }
    
    public void setOnDownloadListener(OnDownloadListener listener) {
        this.listener = listener;
    }
    
    public void downloadSong(Song song) {
        if (isDownloaded(song)) return;
        
        downloadExecutor.execute(() -> {
            try {
                if (listener != null) {
                    listener.onDownloadStarted(song);
                }
                
                String fileName = sanitizeFileName(song.getName() + "_" + song.getArtistName() + ".mp3");
                File downloadDir = new File(context.getExternalFilesDir(Environment.DIRECTORY_MUSIC), "downloads");
                if (!downloadDir.exists()) {
                    downloadDir.mkdirs();
                }
                
                File outputFile = new File(downloadDir, fileName);
                
                URL url = new URL(song.getAudioUrl());
                HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                connection.connect();
                
                int fileLength = connection.getContentLength();
                InputStream input = connection.getInputStream();
                FileOutputStream output = new FileOutputStream(outputFile);
                
                byte[] buffer = new byte[4096];
                long total = 0;
                int count;
                
                while ((count = input.read(buffer)) != -1) {
                    total += count;
                    output.write(buffer, 0, count);
                    
                    if (fileLength > 0 && listener != null) {
                        int progress = (int) (total * 100 / fileLength);
                        listener.onDownloadProgress(song, progress);
                    }
                }
                
                output.flush();
                output.close();
                input.close();
                
                // Save download info
                saveDownloadInfo(song, outputFile.getAbsolutePath());
                
                // Sync with Repository
                if (repository != null) {
                    repository.markSongAsDownloaded(song.getId(), outputFile.getAbsolutePath());
                }
                
                if (listener != null) {
                    listener.onDownloadCompleted(song, outputFile.getAbsolutePath());
                }
                
            } catch (IOException e) {
                if (listener != null) {
                    listener.onDownloadFailed(song, e.getMessage());
                }
            }
        });
    }
    
    public void deleteSong(Song song) {
        String filePath = getDownloadedFilePath(song);
        if (filePath != null) {
            File file = new File(filePath);
            if (file.exists()) {
                file.delete();
            }
            removeDownloadInfo(song);
            
            // Sync with Repository
            if (repository != null) {
                repository.updateDownloadStatus(song.getId(), false);
            }
        }
    }
    
    public boolean isDownloaded(Song song) {
        List<Song> downloaded = getDownloadedSongs();
        for (Song downloadedSong : downloaded) {
            if (downloadedSong.getId().equals(song.getId())) {
                return true;
            }
        }
        return false;
    }
    
    public String getDownloadedFilePath(Song song) {
        List<Song> downloaded = getDownloadedSongs();
        for (Song downloadedSong : downloaded) {
            if (downloadedSong.getId().equals(song.getId())) {
                return downloadedSong.getAudioUrl(); // We store local path in audioUrl
            }
        }
        return null;
    }
    
    public List<Song> getDownloadedSongs() {
        String json = prefs.getString("downloaded_songs", "[]");
        Type listType = new TypeToken<List<Song>>(){}.getType();
        List<Song> songs = gson.fromJson(json, listType);
        return songs != null ? songs : new ArrayList<>();
    }
    
    private void saveDownloadInfo(Song song, String localPath) {
        List<Song> downloaded = getDownloadedSongs();
        
        // Create a copy with local path
        Song localSong = new Song(
            song.getId(),
            song.getName(),
            song.getArtistName(),
            song.getArtistId(),
            song.getImageUrl(),
            localPath, // Store local path instead of URL
            String.valueOf(song.getDuration())
        );
        
        downloaded.add(localSong);
        
        String json = gson.toJson(downloaded);
        prefs.edit().putString("downloaded_songs", json).apply();
    }
    
    private void removeDownloadInfo(Song song) {
        List<Song> downloaded = getDownloadedSongs();
        
        // Remove using iterator for API 23 compatibility
        java.util.Iterator<Song> iterator = downloaded.iterator();
        while (iterator.hasNext()) {
            Song s = iterator.next();
            if (s.getId().equals(song.getId())) {
                iterator.remove();
                break;
            }
        }
        
        String json = gson.toJson(downloaded);
        prefs.edit().putString("downloaded_songs", json).apply();
    }
    
    private String sanitizeFileName(String fileName) {
        return fileName.replaceAll("[^a-zA-Z0-9._-]", "_");
    }
    
    public long getDownloadedSize() {
        long totalSize = 0;
        List<Song> downloaded = getDownloadedSongs();
        for (Song song : downloaded) {
            File file = new File(song.getAudioUrl());
            if (file.exists()) {
                totalSize += file.length();
            }
        }
        return totalSize;
    }
    
    public void clearAllDownloads() {
        List<Song> downloaded = getDownloadedSongs();
        for (Song song : downloaded) {
            File file = new File(song.getAudioUrl());
            if (file.exists()) {
                file.delete();
            }
        }
        prefs.edit().remove("downloaded_songs").apply();
    }
}
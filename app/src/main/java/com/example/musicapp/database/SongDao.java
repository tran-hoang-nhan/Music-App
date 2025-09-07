package com.example.musicapp.database;

import androidx.lifecycle.LiveData;
import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;
import androidx.room.Update;

import java.util.List;

@Dao
public interface SongDao {
    
    @Query("SELECT * FROM songs ORDER BY timestamp DESC")
    LiveData<List<SongEntity>> getAllSongs();
    
    @Query("SELECT * FROM songs WHERE isFavorite = 1 ORDER BY timestamp DESC")
    LiveData<List<SongEntity>> getFavoriteSongs();
    
    @Query("SELECT * FROM songs WHERE isDownloaded = 1 ORDER BY timestamp DESC")
    LiveData<List<SongEntity>> getDownloadedSongs();
    
    @Query("SELECT * FROM songs ORDER BY timestamp DESC LIMIT 50")
    LiveData<List<SongEntity>> getRecentSongs();
    
    @Query("SELECT * FROM songs WHERE name LIKE :query OR artistName LIKE :query")
    LiveData<List<SongEntity>> searchSongs(String query);
    
    @Query("SELECT * FROM songs WHERE id = :songId")
    SongEntity getSongById(String songId);
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insertSong(SongEntity song);
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insertSongs(List<SongEntity> songs);
    
    @Update
    void updateSong(SongEntity song);
    
    @Query("UPDATE songs SET isFavorite = :isFavorite WHERE id = :songId")
    void updateFavoriteStatus(String songId, boolean isFavorite);
    
    @Query("UPDATE songs SET isDownloaded = :isDownloaded WHERE id = :songId")
    void updateDownloadStatus(String songId, boolean isDownloaded);
    
    @Query("DELETE FROM songs WHERE id = :songId")
    void deleteSong(String songId);
    
    @Query("DELETE FROM songs")
    void deleteAllSongs();
}
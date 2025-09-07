package com.example.musicapp.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Handler;
import android.os.Looper;
import android.util.LruCache;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.request.RequestOptions;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class PerformanceOptimizer {
    
    private static PerformanceOptimizer instance;
    private final Context context;
    private LruCache<String, Bitmap> memoryCache;
    private final ExecutorService backgroundExecutor;
    private final Handler mainHandler;
    
    // Cache sizes
    private static final int MEMORY_CACHE_SIZE = 1024 * 1024 * 20; // 20MB
    private static final int MAX_BACKGROUND_THREADS = 4;
    
    private PerformanceOptimizer(Context context) {
        this.context = context.getApplicationContext();
        this.mainHandler = new Handler(Looper.getMainLooper());
        this.backgroundExecutor = Executors.newFixedThreadPool(MAX_BACKGROUND_THREADS);
        
        // Initialize memory cache
        initMemoryCache();
        
        // Configure Glide for better performance
        configureGlide();
    }
    
    public static synchronized PerformanceOptimizer getInstance(Context context) {
        if (instance == null) {
            instance = new PerformanceOptimizer(context);
        }
        return instance;
    }
    
    private void initMemoryCache() {
        memoryCache = new LruCache<>(MEMORY_CACHE_SIZE) {
            @Override
            protected int sizeOf(String key, Bitmap bitmap) {
                return bitmap.getByteCount();
            }
        };
    }
    
    private void configureGlide() {
        // Glide configuration is done in AppGlideModule
        // This method can be used for runtime optimizations
    }
    
    // Image loading optimization
    public RequestOptions getOptimizedImageOptions() {
        return new RequestOptions()
            .diskCacheStrategy(DiskCacheStrategy.ALL)
            .skipMemoryCache(false)
            .override(300, 300) // Resize to standard size
            .centerCrop();
    }
    
    // Memory management
    public void addBitmapToMemoryCache(String key, Bitmap bitmap) {
        if (getBitmapFromMemCache(key) == null && bitmap != null) {
            memoryCache.put(key, bitmap);
        }
    }
    
    public Bitmap getBitmapFromMemCache(String key) {
        return memoryCache.get(key);
    }
    
    public void clearMemoryCache() {
        memoryCache.evictAll();
    }
    
    // Background task execution
    public void executeInBackground(Runnable task) {
        backgroundExecutor.execute(task);
    }
    
    public void executeOnMainThread(Runnable task) {
        mainHandler.post(task);
    }
    
    public void executeOnMainThreadDelayed(Runnable task, long delayMs) {
        mainHandler.postDelayed(task, delayMs);
    }
    
    // Performance monitoring
    public void logPerformance(String tag, long startTime) {
        long duration = System.currentTimeMillis() - startTime;
        if (duration > 100) { // Log only slow operations
            android.util.Log.w("Performance", tag + " took " + duration + "ms");
        }
    }
    
    // Memory optimization
    public void optimizeMemory() {
        // Clear Glide memory cache
        Glide.get(context).clearMemory();
        
        // Clear our memory cache
        clearMemoryCache();
        
        // Suggest garbage collection
        System.gc();
    }
    
    // Battery optimization
    public void optimizeBattery() {
        // Reduce background processing
        // This can be expanded based on specific needs
    }
    
    // Cleanup
    public void cleanup() {
        if (backgroundExecutor != null && !backgroundExecutor.isShutdown()) {
            backgroundExecutor.shutdown();
        }
        clearMemoryCache();
    }
    
    // Lazy loading helper
    public interface LazyLoadCallback<T> {
        void onLoaded(T data);
        void onError(Exception e);
    }
    
    public <T> void lazyLoad(LazyLoadTask<T> task, LazyLoadCallback<T> callback) {
        executeInBackground(() -> {
            try {
                T result = task.load();
                executeOnMainThread(() -> callback.onLoaded(result));
            } catch (Exception e) {
                executeOnMainThread(() -> callback.onError(e));
            }
        });
    }
    
    public interface LazyLoadTask<T> {
        T load() throws Exception;
    }
}
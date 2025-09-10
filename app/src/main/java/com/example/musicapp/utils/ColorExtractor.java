package com.example.musicapp.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.palette.graphics.Palette;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;

public class ColorExtractor {
    
    public interface OnColorExtractedListener {
        void onColorExtracted(int dominantColor, int vibrantColor);
    }
    
    public interface OnSingleColorExtractedListener {
        void onColorExtracted(int color);
    }
    
    public static void extractColorsFromBitmap(Bitmap bitmap, OnColorExtractedListener listener) {
        if (bitmap == null || listener == null) return;
        
        Palette.from(bitmap).generate(palette -> {
            int dominantColor = Color.parseColor("#1E88E5"); // Default blue
            int vibrantColor = Color.parseColor("#2196F3");   // Default light blue
            
            if (palette != null) {
                // Try to get vibrant color first
                Palette.Swatch vibrantSwatch = palette.getVibrantSwatch();
                if (vibrantSwatch != null) {
                    dominantColor = vibrantSwatch.getRgb();
                    vibrantColor = lightenColor(dominantColor, 0.2f);
                } else {
                    // Fallback to dominant color
                    Palette.Swatch dominantSwatch = palette.getDominantSwatch();
                    if (dominantSwatch != null) {
                        dominantColor = dominantSwatch.getRgb();
                        vibrantColor = lightenColor(dominantColor, 0.2f);
                    } else {
                        // Try muted colors
                        Palette.Swatch mutedSwatch = palette.getMutedSwatch();
                        if (mutedSwatch != null) {
                            dominantColor = mutedSwatch.getRgb();
                            vibrantColor = lightenColor(dominantColor, 0.2f);
                        }
                    }
                }
            }
            
            listener.onColorExtracted(dominantColor, vibrantColor);
        });
    }
    
    private static int lightenColor(int color, float factor) {
        int red = Color.red(color);
        int green = Color.green(color);
        int blue = Color.blue(color);
        
        red = Math.min(255, (int) (red + (255 - red) * factor));
        green = Math.min(255, (int) (green + (255 - green) * factor));
        blue = Math.min(255, (int) (blue + (255 - blue) * factor));
        
        return Color.rgb(red, green, blue);
    }
    
    public static int darkenColor(int color, float factor) {
        int red = Color.red(color);
        int green = Color.green(color);
        int blue = Color.blue(color);
        
        red = (int) (red * (1 - factor));
        green = (int) (green * (1 - factor));
        blue = (int) (blue * (1 - factor));
        
        return Color.rgb(red, green, blue);
    }
    
    // Extract dominant color from image URL
    public static void extractDominantColor(Context context, String imageUrl, OnSingleColorExtractedListener listener) {
        Glide.with(context)
                .asBitmap()
                .load(imageUrl)
                .into(new CustomTarget<Bitmap>() {
                    @Override
                    public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                        Palette.from(resource).generate(palette -> {
                            int dominantColor = Color.parseColor("#667eea"); // Default
                            
                            if (palette != null) {
                                Palette.Swatch vibrantSwatch = palette.getVibrantSwatch();
                                if (vibrantSwatch != null) {
                                    dominantColor = vibrantSwatch.getRgb();
                                } else {
                                    Palette.Swatch dominantSwatch = palette.getDominantSwatch();
                                    if (dominantSwatch != null) {
                                        dominantColor = dominantSwatch.getRgb();
                                    }
                                }
                            }
                            
                            if (listener != null) {
                                listener.onColorExtracted(dominantColor);
                            }
                        });
                    }

                    @Override
                    public void onLoadCleared(@Nullable Drawable placeholder) {}
                });
    }
    
    // Apply gradient background to view
    public static void applyGradientBackground(View view, int color) {
        int darkerColor = darkenColor(color, 0.4f);
        int darkestColor = Color.parseColor("#121212");
        
        GradientDrawable gradient = new GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                new int[]{color, darkerColor, darkestColor}
        );
        
        view.setBackground(gradient);
    }
    
    // Check if color is light (for text color contrast)
    public static boolean isColorLight(int color) {
        double darkness = 1 - (0.299 * Color.red(color) + 0.587 * Color.green(color) + 0.114 * Color.blue(color)) / 255;
        return darkness < 0.5;
    }
}
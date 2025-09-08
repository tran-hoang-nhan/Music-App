package com.example.musicapp.utils;

import android.content.Context;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;

public class AnimationHelper {
    
    public static void fadeIn(Context context, View view) {
        Animation fadeIn = AnimationUtils.loadAnimation(context, com.example.musicapp.R.anim.fade_in);
        view.startAnimation(fadeIn);
    }
    
    public static void fadeOut(Context context, View view) {
        Animation fadeOut = AnimationUtils.loadAnimation(context, com.example.musicapp.R.anim.fade_out);
        view.startAnimation(fadeOut);
    }
    
    public static void slideUp(Context context, View view) {
        Animation slideUp = AnimationUtils.loadAnimation(context, com.example.musicapp.R.anim.slide_up);
        view.startAnimation(slideUp);
    }
    
    public static void slideDown(Context context, View view) {
        Animation slideDown = AnimationUtils.loadAnimation(context, com.example.musicapp.R.anim.slide_down);
        view.startAnimation(slideDown);
    }
    
    public static void scaleIn(Context context, View view) {
        Animation scaleIn = AnimationUtils.loadAnimation(context, com.example.musicapp.R.anim.scale_in);
        view.startAnimation(scaleIn);
    }
    
    public static void bounce(Context context, View view) {
        Animation bounce = AnimationUtils.loadAnimation(context, com.example.musicapp.R.anim.bounce);
        view.startAnimation(bounce);
    }
    
    public static void animateButton(Context context, View button, Runnable onComplete) {
        bounce(context, button);
        if (onComplete != null) {
            button.postDelayed(onComplete, 300);
        }
    }
}
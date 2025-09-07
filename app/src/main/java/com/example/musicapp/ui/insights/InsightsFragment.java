package com.example.musicapp.ui.insights;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.example.musicapp.R;
import com.example.musicapp.personalization.PersonalizationManager;
import com.example.musicapp.player.MusicPlayerManager;

import java.util.Map;

public class InsightsFragment extends Fragment {

    private PersonalizationManager personalizationManager;
    private MusicPlayerManager playerManager;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_insights, container, false);

        personalizationManager = PersonalizationManager.getInstance(requireContext());
        playerManager = MusicPlayerManager.getInstance(requireContext());

        setupInsights(view);
        return view;
    }

    private void setupInsights(View view) {
        TextView tvListeningTime = view.findViewById(R.id.tvListeningTime);
        TextView tvFavoriteGenre = view.findViewById(R.id.tvFavoriteGenre);
        TextView tvRecentlyPlayed = view.findViewById(R.id.tvRecentlyPlayed);
        TextView tvFavorites = view.findViewById(R.id.tvFavorites);

        Map<String, Object> insights = personalizationManager.getUserInsights();

        tvListeningTime.setText("Tổng thời gian nghe: " + insights.get("totalListeningTime"));
        tvFavoriteGenre.setText("Thể loại yêu thích: " + insights.get("favoriteGenre"));
        tvRecentlyPlayed.setText("Bài hát gần đây: " + playerManager.getRecentlyPlayed().size());
        tvFavorites.setText("Bài hát yêu thích: " + playerManager.getFavorites().size());
    }
}
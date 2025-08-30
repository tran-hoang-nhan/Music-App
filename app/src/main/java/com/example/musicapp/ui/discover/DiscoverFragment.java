package com.example.musicapp.ui.discover;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.SearchView;
import androidx.fragment.app.Fragment;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.musicapp.R;
import com.example.musicapp.model.Genre;
import com.example.musicapp.model.GenreAdapter;

import java.util.List;

public class DiscoverFragment extends Fragment {
    
    private Handler searchHandler = new Handler(Looper.getMainLooper());
    private Runnable searchRunnable;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_discover, container, false);

        SearchView searchView = view.findViewById(R.id.searchView);
        RecyclerView recyclerGenres = view.findViewById(R.id.recyclerGenres);
        recyclerGenres.setLayoutManager(new GridLayoutManager(getContext(), 2));

        List<Genre> genres = Genre.getDefaultGenres();

        GenreAdapter adapter = new GenreAdapter(getContext(), genres, genre -> {
            Bundle bundle = new Bundle();
            bundle.putString("genre_name", genre.getName());

            NavController navController = Navigation.findNavController(
                    requireActivity(),
                    R.id.nav_host_fragment_activity_main
            );
            navController.navigate(R.id.navigation_genre_detail, bundle);
        });
        recyclerGenres.setAdapter(adapter);

        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                if (query == null || query.isEmpty()) return false;

                Bundle bundle = new Bundle();
                bundle.putString("query", query);

                NavController navController = Navigation.findNavController(requireActivity(), R.id.nav_host_fragment_activity_main);
                navController.navigate(R.id.navigation_search, bundle);
                return true;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                // Remove previous search callback
                if (searchRunnable != null) {
                    searchHandler.removeCallbacks(searchRunnable);
                }
                
                searchRunnable = () -> {
                    String query = newText.trim();
                    if (!query.isEmpty() && query.length() >= 2) {
                        Bundle bundle = new Bundle();
                        bundle.putString("query", query);

                        NavController navController = Navigation.findNavController(requireActivity(), R.id.nav_host_fragment_activity_main);
                        navController.navigate(R.id.navigation_search, bundle);
                    }
                };
                
                // Debounce: wait 800ms for SearchView (longer than EditText)
                searchHandler.postDelayed(searchRunnable, 800);
                return true;
            }
        });

        return view;
    }
    
    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (searchHandler != null && searchRunnable != null) {
            searchHandler.removeCallbacks(searchRunnable);
        }
    }
}
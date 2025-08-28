package com.example.musicapp.ui.discover;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

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

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_discover, container, false);

        SearchView searchView = view.findViewById(R.id.searchView);
        RecyclerView recyclerGenres = view.findViewById(R.id.recyclerGenres);
        recyclerGenres.setLayoutManager(new GridLayoutManager(getContext(), 2));

        // ✅ Lấy danh sách genre thủ công
        List<Genre> genres = Genre.getDefaultGenres();

        // Gắn adapter
        // TODO: Navigate sang màn hình danh sách bài hát theo genre này
        GenreAdapter adapter = new GenreAdapter(getContext(), genres, genre -> {
            Toast.makeText(getContext(), "Chọn: " + genre.getName(), Toast.LENGTH_SHORT).show();
            // TODO: Navigate sang màn hình danh sách bài hát theo genre này
        });
        recyclerGenres.setAdapter(adapter);

        // Giữ lại Search để điều hướng sang SearchFragment
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
                return false;
            }
        });


        return view;
    }
}

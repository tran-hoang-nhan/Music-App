package com.example.musicapp.ui.profile;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.navigation.fragment.NavHostFragment;

import com.example.musicapp.R;
import com.example.musicapp.databinding.FragmentProfileBinding;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

public class ProfileFragment extends Fragment {

    private FragmentProfileBinding binding;
    private FirebaseAuth auth;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        binding = FragmentProfileBinding.inflate(inflater, container, false);
        auth = FirebaseAuth.getInstance();

        updateUI();

        // nút đăng nhập
        binding.btnGoLogin.setOnClickListener(v ->
                NavHostFragment.findNavController(this)
                        .navigate(R.id.action_profile_to_login)
        );

        // nút đăng xuất
        binding.btnLogout.setOnClickListener(v -> {
            auth.signOut();
            Toast.makeText(getContext(), "Đã đăng xuất", Toast.LENGTH_SHORT).show();
            updateUI();
        });

        return binding.getRoot();
    }

    private void updateUI() {
        FirebaseUser user = auth.getCurrentUser();
        if (user == null) {
            binding.layoutNotLoggedIn.setVisibility(View.VISIBLE);
            binding.layoutLoggedIn.setVisibility(View.GONE);
        } else {
            binding.layoutNotLoggedIn.setVisibility(View.GONE);
            binding.layoutLoggedIn.setVisibility(View.VISIBLE);

            binding.tvUserName.setText(user.getDisplayName() != null ? user.getDisplayName() : "Người dùng");
            binding.tvUserEmail.setText(user.getEmail());
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        updateUI();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}

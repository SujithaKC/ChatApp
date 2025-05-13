// This file defines the `FriendProfileScreen` class, which displays the profile of a friend.
// It includes details such as name, bio, profile picture, and common groups.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/group_model.dart';
import '../../../routes/app_routes.dart';
import '../../chat/viewmodel/group_chat_viewmodel.dart';
import '../viewmodel/profile_viewmodel.dart';

class FriendProfileScreen extends StatelessWidget {
  final String friendId; // The ID of the friend whose profile is being displayed.

  const FriendProfileScreen({Key? key, required this.friendId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provides the ProfileViewModel to fetch and manage the friend's profile data.
        ChangeNotifierProvider(create: (_) => ProfileViewModel()..fetchUser(friendId)),
        // Provides the GroupChatViewModel to fetch and manage group-related data.
        ChangeNotifierProvider(create: (_) => GroupChatViewModel()),
      ],
      child: Consumer<ProfileViewModel>(
        builder: (context, profileViewModel, child) {
          // Displays a loading indicator while the profile data is being fetched.
          if (profileViewModel.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // Displays an error message if the profile data could not be fetched.
          if (profileViewModel.user == null) {
            return Scaffold(
              body: Center(child: Text(profileViewModel.errorMessage ?? 'User not found')),
            );
          }
          return Consumer<GroupChatViewModel>(
            builder: (context, groupChatViewModel, child) {
              final currentUserId = FirebaseAuth.instance.currentUser!.uid; // The ID of the current user.
              return Scaffold(
                appBar: AppBar(
                  title: Text(profileViewModel.user!.displayName), // Displays the friend's name in the app bar.
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Displays the friend's profile picture as a circle avatar.
                      CircleAvatar(
                        radius: 50,
                        child: Text(
                          profileViewModel.user!.displayName.isNotEmpty
                              ? profileViewModel.user!.displayName.substring(0, 1)
                              : '?',
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Displays the friend's email address.
                      Text(
                        profileViewModel.user!.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Displays the friend's bio or a placeholder if no bio is available.
                      Text(
                        profileViewModel.user!.bio.isNotEmpty
                            ? profileViewModel.user!.bio
                            : 'No bio available',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Displays a heading for the common groups section.
                      Text(
                        'Common Groups',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Displays a list of common groups between the current user and the friend.
                      Expanded(
                        child: StreamBuilder<List<GroupModel>>(
                          stream: groupChatViewModel.getGroups(), // Fetches the list of groups.
                          builder: (context, snapshot) {
                            // Displays an error message if there is an issue fetching the groups.
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              );
                            }
                            // Displays a loading indicator while the groups are being fetched.
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            // Filters the groups to show only those that both the current user and the friend are members of.
                            final groups = snapshot.data!
                                .where((group) =>
                                    group.members.contains(currentUserId) &&
                                    group.members.contains(friendId))
                                .toList();
                            // Displays a message if no common groups are found.
                            if (groups.isEmpty) {
                              return Center(
                                child: Text(
                                  'No common groups found',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              );
                            }
                            // Displays a list of common groups.
                            return ListView.builder(
                              itemCount: groups.length,
                              itemBuilder: (context, index) {
                                final group = groups[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      group.name.isNotEmpty
                                          ? group.name.substring(0, 1)
                                          : '?',
                                    ),
                                  ),
                                  title: Text(
                                    group.name,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  subtitle: Text(
                                    '${group.members.length} members',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.groupChat, // Navigates to the group chat screen.
                                    arguments: group.id,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
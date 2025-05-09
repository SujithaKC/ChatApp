import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/group_model.dart';
import '../../../routes/app_routes.dart';
import '../../chat/viewmodel/group_chat_viewmodel.dart';
import '../viewmodel/profile_viewmodel.dart';

class FriendProfileScreen extends StatelessWidget {
  final String friendId;

  const FriendProfileScreen({Key? key, required this.friendId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileViewModel()..fetchUser(friendId)),
        ChangeNotifierProvider(create: (_) => GroupChatViewModel()),
      ],
      child: Consumer<ProfileViewModel>(
        builder: (context, profileViewModel, child) {
          if (profileViewModel.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (profileViewModel.user == null) {
            return Scaffold(
              body: Center(child: Text(profileViewModel.errorMessage ?? 'User not found')),
            );
          }
          return Consumer<GroupChatViewModel>(
            builder: (context, groupChatViewModel, child) {
              final currentUserId = FirebaseAuth.instance.currentUser!.uid;
              return Scaffold(
                appBar: AppBar(
                  title: Text(profileViewModel.user!.displayName),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      Text(
                        profileViewModel.user!.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profileViewModel.user!.bio.isNotEmpty
                            ? profileViewModel.user!.bio
                            : 'No bio available',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                     Text(
  'Common Groups',
  style: Theme.of(context).textTheme.headlineSmall,
  textAlign: TextAlign.center,
),


                      const SizedBox(height: 16),
                      Expanded(
                        child: StreamBuilder<List<GroupModel>>(
                          stream: groupChatViewModel.getGroups(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final groups = snapshot.data!
                                .where((group) =>
                                    group.members.contains(currentUserId) &&
                                    group.members.contains(friendId))
                                .toList();
                            if (groups.isEmpty) {
                              return Center(
                                child: Text(
                                  'No common groups found',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              );
                            }
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
                                    AppRoutes.groupChat,
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
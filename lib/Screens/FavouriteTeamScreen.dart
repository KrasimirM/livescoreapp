import 'package:LiveScore/Widgets/MatchFilter.dart';
import 'package:LiveScore/Widgets/MatchTile.dart';
import 'package:LiveScore/Widgets/TeamInfo.dart';
import 'package:LiveScore/Widgets/LoadingView.dart';
import 'package:LiveScore/Widgets/FavoriteTeamInsights.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:LiveScore/services/HttpService.dart';
import 'package:LiveScore/services/FirestoreService.dart';
import 'package:LiveScore/constants.dart';
import 'LeagueSelectionScreen.dart';

class Favouriteteamscreen extends StatefulWidget {
  final int refreshToken;
  final VoidCallback? onFavoriteTeamChanged;

  const Favouriteteamscreen({
    Key? key,
    this.refreshToken = 0,
    this.onFavoriteTeamChanged,
  }) : super(key: key);

  @override
  State<Favouriteteamscreen> createState() => _FavouriteteamscreenState();
}

class _FavouriteteamscreenState extends State<Favouriteteamscreen> {
  String? _favoriteTeamName;
  String? _favoriteTeamId;
  String? _favoriteTeamCrest;
  List _matches = [];
  List _pastMatches = [];
  List _futureMatches = [];
  bool _isLoadingUser = true;
  bool _isLoadingMatches = false;
  String? _errorMessage;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HttpService _httpService = HttpService();

  String _selectedFilter = 'upcoming';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didUpdateWidget(covariant Favouriteteamscreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _loadUserData();
    }
  }

  void _loadUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingUser = true;
      _errorMessage = null;
      _favoriteTeamName = null;
      _favoriteTeamId = null;
      _favoriteTeamCrest = null;
      _matches = [];
      _pastMatches = [];
      _futureMatches = [];
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;
        Map<String, dynamic> userData =
            await _firestoreService.getUserData(uid);
        final teamName = (userData['favorite_team'] ?? '').toString().trim();
        final teamId = (userData['favorite_team_id'] ?? '').toString().trim();

        if (teamName.isNotEmpty && teamId.isNotEmpty) {
          setState(() {
            _favoriteTeamName = teamName;
            _favoriteTeamId = teamId;
          });
          getMatches();
          getTeamDetails(teamId);
        }
      }
    } catch (e) {
      _errorMessage = 'Could not load your profile.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Favorite Team'),
      ),
      body: Center(
        child: _isLoadingUser
            ? LoadingView(message: 'Loading your favorite team...')
            : _errorMessage != null
                ? _buildError(_errorMessage!)
                : _favoriteTeamName == null
                    ? _buildNoFavoriteTeam()
                    : _buildFavoriteTeam(),
      ),
    );
  }

  Widget _buildNoFavoriteTeam() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'No favourite team selected',
          style: TextStyle(color: AppColors.textColor),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LeagueSelectionScreen()),
            );
            if (result != null) {
              final teamId = result['id'].toString();
              setState(() {
                _favoriteTeamName = result['name'];
                _favoriteTeamId = teamId;
              });
              getMatches();
              getTeamDetails(teamId);
              await _saveFavoriteTeam();
              widget.onFavoriteTeamChanged?.call();
            }
          },
          child: Text('Select Favourite Team'),
        ),
      ],
    );
  }

  Widget _buildFavoriteTeam() {
    return Column(
      children: [
        SizedBox(height: 20),
        _favoriteTeamCrest != null
            ? TeamInfo(
                teamName: _favoriteTeamName!,
                crestUrl: _favoriteTeamCrest!,
              )
            : Container(),
        SizedBox(height: 20),
        _isLoadingMatches
            ? Expanded(child: LoadingView(message: 'Loading matches...'))
            : _matches.isEmpty
                ? Expanded(
                    child: _buildEmptyState(
                      'No matches found for this team.',
                    ),
                  )
                : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildLastPlayedMatch(),
                          SizedBox(height: 20),
                          FavoriteTeamInsights(
                            teamId: _favoriteTeamId!,
                            pastMatches: _pastMatches,
                          ),
                          SizedBox(height: 20),
                          MatchFilter(
                            selectedFilter: _selectedFilter,
                            onChanged: (String newValue) {
                              setState(() {
                                _selectedFilter = newValue;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          _buildMatchList(),
                        ],
                      ),
                    ),
                  ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        style: TextStyle(color: AppColors.errorColor, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: TextStyle(color: AppColors.textColor, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLastPlayedMatch() {
    if (_pastMatches.isEmpty) return Container();

    final lastMatch = _pastMatches.first;
    return Column(
      children: [
        Text(
          'Last Played Match',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        MatchTile(match: lastMatch),
      ],
    );
  }

  Widget _buildMatchList() {
    List matchesToDisplay =
        _selectedFilter == 'past' ? _pastMatches : _futureMatches;

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: matchesToDisplay.length,
      itemBuilder: (context, index) {
        return MatchTile(match: matchesToDisplay[index]);
      },
    );
  }

  Future<void> _saveFavoriteTeam() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email ?? '';
      await _firestoreService.updateFavoriteTeam(
          email, _favoriteTeamName!, _favoriteTeamId!);
    }
  }

  Future<void> getMatches() async {
    setState(() {
      _isLoadingMatches = true;
      _errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final oneYearAgo =
          DateTime(now.year - 1, now.month, now.day).toString().split(' ')[0];
      final today = now.toString().split(' ')[0];

      final pastMatches = await _httpService.fetchMatches(_favoriteTeamId!,
          dateFrom: oneYearAgo, dateTo: today);

      final nextYear =
          DateTime(now.year + 1, now.month, now.day).toString().split(' ')[0];
      final futureMatches = await _httpService.fetchMatches(_favoriteTeamId!,
          dateFrom: today, dateTo: nextYear);

      pastMatches.sort((a, b) =>
          DateTime.parse(b['utcDate']).compareTo(DateTime.parse(a['utcDate'])));

      setState(() {
        _pastMatches = pastMatches;
        _futureMatches = futureMatches;
        _matches = _futureMatches;
        _isLoadingMatches = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMatches = false;
          _errorMessage = 'Could not load matches.';
        });
      }
    }
  }

  void getTeamDetails(String teamId) async {
    try {
      final crest = await _httpService.fetchTeamDetails(teamId);
      setState(() {
        _favoriteTeamCrest = crest;
      });
    } catch (e) {
      print('Error fetching team details: $e');
    }
  }
}

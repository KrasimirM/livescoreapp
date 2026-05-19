import 'package:LiveScore/services/HttpService.dart';
import 'package:flutter/material.dart';
import 'package:LiveScore/constants.dart';
import 'package:LiveScore/Widgets/CompetitionBracketView.dart';
import 'package:LiveScore/Widgets/CompetitionEmptyState.dart';
import 'package:LiveScore/Widgets/CompetitionHeroHeader.dart';
import 'package:LiveScore/Widgets/CompetitionOverviewView.dart';
import 'package:LiveScore/Widgets/CompetitionTableView.dart';
import 'package:LiveScore/Widgets/LoadingView.dart';

class TableScreen extends StatefulWidget {
  final String code;
  final String name;
  const TableScreen({required Key key, required this.code, required this.name})
      : super(key: key);
  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List _standings = [];
  List _matches = [];
  Map<String, List> _bracketMatchesByStage = {};
  bool _isLoading = true;
  String? _errorMessage;
  final HttpService _httpService = HttpService();

  bool get _hasBracket =>
      widget.code == 'CL' ||
      widget.code == 'WC' ||
      widget.code == 'CLI' ||
      widget.code == 'EC';

  @override
  void initState() {
    getCompetitionData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tabCount = _hasBracket ? 3 : 2;

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          automaticallyImplyLeading: true,
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: AppColors.accentColor,
            labelColor: AppColors.textColor,
            unselectedLabelColor: AppColors.subtitleTextColor,
            tabs: [
              Tab(
                icon: Icon(Icons.dashboard_customize),
                text: 'Hub',
              ),
              Tab(
                icon: Icon(Icons.table_rows),
                text: 'Table',
              ),
              if (_hasBracket)
                Tab(
                  icon: Icon(Icons.account_tree),
                  text: 'Bracket',
                ),
            ],
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Container(
        color: AppColors.backgroundColor,
        child: LoadingView(message: 'Loading competition...'),
      );
    }

    if (_errorMessage != null) {
      return CompetitionEmptyState(
        title: 'Competition data is unavailable',
        message: _errorMessage!,
        color: AppColors.errorColor,
        icon: Icons.error_outline,
        actions: [
          CompetitionEmptyAction(
            icon: Icons.refresh,
            title: 'Try again',
            subtitle: 'Reload standings and matches from the API',
            color: AppColors.primaryColor,
            onTap: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              getCompetitionData();
            },
          ),
        ],
      );
    }

    final content = TabBarView(
      children: [
        _buildOverviewBody(),
        _buildTableBody(),
        if (_hasBracket) _buildBracketBody(),
      ],
    );

    return Column(
      children: [
        CompetitionHeroHeader(
          name: widget.name,
          code: widget.code,
          teamCount: _teamCount,
          bracketMatchCount: _bracketMatchesByStage.values.fold<int>(
            0,
            (sum, matches) => sum + matches.length,
          ),
        ),
        Expanded(child: content),
      ],
    );
  }

  Future<void> getCompetitionData() async {
    try {
      final standings = await _httpService.fetchStandings(widget.code);
      List matches = [];
      Map<String, List> bracketMatchesByStage = {};

      try {
        matches = await _httpService.fetchCompetitionMatches(widget.code);
      } catch (_) {
        matches = [];
      }

      if (_hasBracket && matches.isNotEmpty) {
        bracketMatchesByStage = _groupBracketMatches(matches);
      }

      if (!mounted) return;
      setState(() {
        _standings = standings;
        _matches = matches;
        _bracketMatchesByStage = bracketMatchesByStage;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load competition data.';
        _isLoading = false;
      });
    }
  }

  Widget _buildOverviewBody() {
    return CompetitionOverviewView(
      competitionName: widget.name,
      standings: _standings,
      matches: _matches,
      hasBracket: _hasBracket,
    );
  }

  int get _teamCount {
    return _standings.fold<int>(
      0,
      (sum, standing) => sum + ((standing['table'] ?? []) as List).length,
    );
  }

  Map<String, List> _groupBracketMatches(List matches) {
    final bracketMatches = matches.where(_isBracketMatch).toList();
    bracketMatches.sort((a, b) {
      final stageCompare =
          _stageOrder(a['stage']).compareTo(_stageOrder(b['stage']));
      if (stageCompare != 0) return stageCompare;
      return _matchDate(a).compareTo(_matchDate(b));
    });

    final grouped = <String, List>{};
    for (final match in bracketMatches) {
      final stage = (match['stage'] ?? '').toString();
      grouped.putIfAbsent(stage, () => []).add(match);
    }
    return grouped;
  }

  bool _isBracketMatch(dynamic match) {
    final stage = (match['stage'] ?? '').toString();
    return stage.contains('PLAY_OFF') ||
        stage.contains('PLAYOFF') ||
        stage.contains('LAST_') ||
        stage.contains('ROUND_OF_16') ||
        stage.contains('ROUND_16') ||
        stage.contains('QUARTER') ||
        stage.contains('SEMI') ||
        stage == 'FINAL';
  }

  int _stageOrder(dynamic stageValue) {
    final stage = (stageValue ?? '').toString();
    const order = {
      'KNOCKOUT_ROUND_PLAY_OFFS': 0,
      'PLAY_OFFS': 0,
      'PLAYOFFS': 0,
      'LAST_16': 1,
      'ROUND_OF_16': 1,
      'ROUND_16': 1,
      'QUARTER_FINALS': 2,
      'SEMI_FINALS': 3,
      'FINAL': 4,
    };
    return order[stage] ?? 99;
  }

  DateTime _matchDate(dynamic match) {
    return DateTime.tryParse((match['utcDate'] ?? '').toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _stageLabel(String stage) {
    const labels = {
      'KNOCKOUT_ROUND_PLAY_OFFS': 'Knockout Play-offs',
      'PLAY_OFFS': 'Knockout Play-offs',
      'PLAYOFFS': 'Knockout Play-offs',
      'LAST_16': 'Round of 16',
      'ROUND_OF_16': 'Round of 16',
      'ROUND_16': 'Round of 16',
      'QUARTER_FINALS': 'Quarter-finals',
      'SEMI_FINALS': 'Semi-finals',
      'FINAL': 'Final',
    };
    return labels[stage] ??
        stage
            .split('_')
            .where((part) => part.isNotEmpty)
            .map((part) => part[0] + part.substring(1).toLowerCase())
            .join(' ');
  }

  Widget _buildTableBody() {
    if (_standings.isEmpty || _teamCount == 0) {
      return CompetitionEmptyState(
        title: 'No table data yet',
        message:
            'The API did not return standings for this competition. You can still use the parts that are available.',
        icon: Icons.table_rows,
        color: AppColors.accentColor,
        actions: _availableActions(
          includeHub: true,
          includeMatches: _matches.isNotEmpty,
          includeBracket: _hasBracket && _bracketMatchesByStage.isNotEmpty,
        ),
      );
    }

    return CompetitionTableView(standings: _standings);
  }

  Widget _buildBracketBody() {
    if (_bracketMatchesByStage.isEmpty) {
      return CompetitionEmptyState(
        title: 'Bracket is not available',
        message:
            'This competition has no knockout bracket data from the API right now. Check the hub, matches or table instead.',
        icon: Icons.account_tree,
        color: AppColors.secondaryAccentColor,
        actions: _availableActions(
          includeHub: true,
          includeTable: _teamCount > 0,
          includeMatches: _matches.isNotEmpty,
        ),
      );
    }

    return CompetitionBracketView(
      matchesByStage: _bracketMatchesByStage,
      stageOrder: _stageOrder,
      stageLabel: _stageLabel,
    );
  }

  List<CompetitionEmptyAction> _availableActions({
    bool includeHub = false,
    bool includeTable = false,
    bool includeMatches = false,
    bool includeBracket = false,
  }) {
    return [
      if (includeHub)
        CompetitionEmptyAction(
          icon: Icons.dashboard_customize,
          title: 'Open competition hub',
          subtitle: 'See available matches, pulse and team spotlight',
          color: AppColors.primaryColor,
          onTap: () => _openTab(0),
        ),
      if (includeTable)
        CompetitionEmptyAction(
          icon: Icons.table_rows,
          title: 'View table',
          subtitle: 'Standings are available for this competition',
          color: AppColors.accentColor,
          onTap: () => _openTab(1),
        ),
      if (includeMatches)
        CompetitionEmptyAction(
          icon: Icons.manage_search,
          title: 'Explore matches',
          subtitle: 'Use the hub to switch between upcoming and recent games',
          color: AppColors.secondaryAccentColor,
          onTap: () => _openTab(0),
        ),
      if (includeBracket)
        CompetitionEmptyAction(
          icon: Icons.account_tree,
          title: 'Open bracket',
          subtitle: 'Knockout matches are available',
          color: AppColors.primaryColor,
          onTap: () => _openTab(2),
        ),
    ];
  }

  void _openTab(int index) {
    DefaultTabController.of(context).animateTo(index);
  }
}

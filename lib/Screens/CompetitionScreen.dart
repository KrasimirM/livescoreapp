import 'package:flutter/material.dart';
import 'package:LiveScore/Screens/TableScreen.dart';
import 'package:LiveScore/Widgets/MatchDaySection.dart';
import 'package:LiveScore/constants.dart';

class CompetitionsScreen extends StatelessWidget {
  CompetitionsScreen({Key? key}) : super(key: key);

  final List<_CompetitionItem> _competitions = const [
    _CompetitionItem(
      image: 'assets/wc.png',
      code: 'WC',
      name: 'FIFA World Cup 2026',
      region: 'Global',
      accent: Color(0xFFFFB02E),
      features: ['Groups', 'Bracket', 'Fixtures'],
      icon: Icons.public,
      featured: true,
    ),
    _CompetitionItem(
      image: 'assets/ucl.png',
      code: 'CL',
      name: 'UEFA Champions League',
      region: 'Europe',
      accent: Color(0xFF4DD6FF),
      features: ['Table', 'Bracket', 'Knockouts'],
      icon: Icons.auto_awesome,
      featured: true,
    ),
    _CompetitionItem(
      image: 'assets/pl.png',
      code: 'PL',
      name: 'Premier League',
      region: 'England',
      accent: Color(0xFF00C896),
      features: ['Table', 'Teams', 'Matches'],
      icon: Icons.shield,
    ),
    _CompetitionItem(
      image: 'assets/laliga.png',
      code: 'PD',
      name: 'LaLiga',
      region: 'Spain',
      accent: Color(0xFFFF5A67),
      features: ['Table', 'Form', 'Teams'],
      icon: Icons.sports_soccer,
    ),
    _CompetitionItem(
      image: 'assets/bundesliga.png',
      code: 'BL1',
      name: 'Bundesliga',
      region: 'Germany',
      accent: Color(0xFFFF7A45),
      features: ['Table', 'Matches', 'Teams'],
      icon: Icons.flash_on,
    ),
    _CompetitionItem(
      image: 'assets/seria.png',
      code: 'SA',
      name: 'Serie A',
      region: 'Italy',
      accent: Color(0xFF7C5CFF),
      features: ['Table', 'Form', 'Matches'],
      icon: Icons.military_tech,
    ),
    _CompetitionItem(
      image: 'assets/ligue1.png',
      code: 'FL1',
      name: 'Ligue 1',
      region: 'France',
      accent: Color(0xFF21D4FD),
      features: ['Table', 'Teams', 'Matches'],
      icon: Icons.stars,
    ),
    _CompetitionItem(
      image: 'assets/nos.png',
      code: 'PPL',
      name: 'Liga Portugal',
      region: 'Portugal',
      accent: Color(0xFF00C896),
      features: ['Table', 'Teams', 'Matches'],
      icon: Icons.flag,
    ),
    _CompetitionItem(
      image: 'assets/logo.png',
      code: 'DED',
      name: 'Eredivisie',
      region: 'Netherlands',
      accent: Color(0xFFFFB02E),
      features: ['Table', 'Goals', 'Teams'],
      icon: Icons.waves,
    ),
    _CompetitionItem(
      image: 'assets/logo.png',
      code: 'BSA',
      name: 'Brasileirao Serie A',
      region: 'Brazil',
      accent: Color(0xFF23D160),
      features: ['Table', 'Form', 'Matches'],
      icon: Icons.park,
    ),
    _CompetitionItem(
      image: 'assets/logo.png',
      code: 'CLI',
      name: 'Copa Libertadores',
      region: 'South America',
      accent: Color(0xFFFFB02E),
      features: ['Groups', 'Bracket', 'Fixtures'],
      icon: Icons.local_fire_department,
      featured: true,
    ),
    _CompetitionItem(
      image: 'assets/logo.png',
      code: 'EC',
      name: 'European Championship',
      region: 'Europe',
      accent: Color(0xFF4DD6FF),
      features: ['Groups', 'Bracket', 'Fixtures'],
      icon: Icons.emoji_events,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final featured = _competitions.where((item) => item.featured).toList();
    final regular = _competitions.where((item) => !item.featured).toList();

    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: MatchDaySection(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                child: _CompetitionsHeader(count: _competitions.length),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 218,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: featured.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return _FeaturedCompetitionCard(item: featured[index]);
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _IdeasStrip(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _CompetitionCard(item: regular[index]),
                  childCount: regular.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompetitionItem {
  final String image;
  final String code;
  final String name;
  final String region;
  final Color accent;
  final List<String> features;
  final IconData icon;
  final bool featured;

  const _CompetitionItem({
    required this.image,
    required this.code,
    required this.name,
    required this.region,
    required this.accent,
    required this.features,
    required this.icon,
    this.featured = false,
  });
}

class _CompetitionsHeader extends StatelessWidget {
  final int count;

  const _CompetitionsHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withAlpha(232),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withAlpha(35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: AppColors.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Competitions',
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count tournaments with tables, teams, matches and brackets',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.subtitleTextColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCompetitionCard extends StatelessWidget {
  final _CompetitionItem item;

  const _FeaturedCompetitionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 286,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openCompetition(context, item),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                item.accent.withAlpha(75),
                AppColors.cardBackgroundColor.withAlpha(245),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: item.accent.withAlpha(120)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CompetitionLogo(item: item, size: 54),
                  const Spacer(),
                  _CodePill(code: item.code, color: item.accent),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 58,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              _FeatureRow(
                features: item.features,
                color: item.accent,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  final _CompetitionItem item;

  const _CompetitionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openCompetition(context, item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundColor.withAlpha(235),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(45),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CompetitionLogo(item: item, size: 48),
                const Spacer(),
                Icon(item.icon, color: item.accent, size: 22),
              ],
            ),
            const Spacer(),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              item.region,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.mutedTextColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _FeatureRow(
                features: item.features.take(2).toList(), color: item.accent),
          ],
        ),
      ),
    );
  }
}

class _CompetitionLogo extends StatelessWidget {
  final _CompetitionItem item;
  final double size;

  const _CompetitionLogo({required this.item, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Image.asset(
        item.image,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(item.icon, color: item.accent),
      ),
    );
  }
}

class _CodePill extends StatelessWidget {
  final String code;
  final Color color;

  const _CodePill({required this.code, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(140)),
      ),
      child: Text(
        code,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final List<String> features;
  final Color color;
  final bool compact;

  const _FeatureRow({
    required this.features,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: features
          .map(
            (feature) => Container(
              constraints: compact ? const BoxConstraints(maxWidth: 82) : null,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 7 : 8,
                vertical: compact ? 5 : 6,
              ),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withAlpha(70)),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  feature,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.subtitleTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _IdeasStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const ideas = [
      _CompetitionIdea(Icons.account_tree, 'Knockout brackets'),
      _CompetitionIdea(Icons.table_rows, 'Live tables'),
      _CompetitionIdea(Icons.trending_up, 'Form watch'),
      _CompetitionIdea(Icons.groups, 'Team browser'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ideas
              .map(
                (idea) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor.withAlpha(220),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: Colors.white.withAlpha(14)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(idea.icon, color: AppColors.accentColor, size: 17),
                      const SizedBox(width: 7),
                      Text(
                        idea.label,
                        style: const TextStyle(
                          color: AppColors.subtitleTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _CompetitionIdea {
  final IconData icon;
  final String label;

  const _CompetitionIdea(this.icon, this.label);
}

void _openCompetition(BuildContext context, _CompetitionItem item) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TableScreen(
        code: item.code,
        key: GlobalKey(),
        name: item.name,
      ),
    ),
  );
}

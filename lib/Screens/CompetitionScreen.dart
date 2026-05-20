import 'package:flutter/material.dart';
import 'package:LiveScore/Models/CompetitionItem.dart';
import 'package:LiveScore/Screens/TableScreen.dart';
import 'package:LiveScore/Widgets/CompetitionCards.dart';
import 'package:LiveScore/Widgets/MatchDaySection.dart';
import 'package:LiveScore/data/competitions_data.dart';

class CompetitionsScreen extends StatelessWidget {
  const CompetitionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final featured = competitionsData.where((item) => item.featured).toList();
    final regular = competitionsData.where((item) => !item.featured).toList();

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
                child: CompetitionsHeader(count: competitionsData.length),
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
                    return FeaturedCompetitionCard(
                      item: featured[index],
                      onOpen: (item) => _openCompetition(context, item),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: IdeasStrip(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => CompetitionCard(
                    item: regular[index],
                    onOpen: (item) => _openCompetition(context, item),
                  ),
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

  void _openCompetition(BuildContext context, CompetitionItem item) {
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
}

const admin = require('firebase-admin');
const path = require('path');

const serviceAccountPath = path.resolve(
  process.cwd(),
  process.argv[2] || './serviceAccountKey.json'
);
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const q = (question, answers, correctAnswerIndex) => ({
  question,
  answers,
  correctAnswerIndex,
});

const quizzes = [
  {
    title: 'World Cup Origins',
    category: 'history',
    questions: [
      q('Which country hosted the first FIFA World Cup?', ['Uruguay', 'Brazil', 'Italy', 'France'], 0),
      q('In which year was the first FIFA World Cup held?', ['1926', '1930', '1934', '1938'], 1),
      q('Which country won the 1966 FIFA World Cup?', ['England', 'Germany', 'Brazil', 'Argentina'], 0),
      q('Who is known for the Hand of God goal?', ['Pele', 'Diego Maradona', 'Zinedine Zidane', 'Ronaldo'], 1),
      q('Which country has won the most World Cups?', ['Germany', 'Argentina', 'Brazil', 'Italy'], 2),
    ],
  },
  {
    title: 'Champions League History',
    category: 'history',
    questions: [
      q('Which club has won the most Champions League titles?', ['AC Milan', 'Liverpool', 'Real Madrid', 'Barcelona'], 2),
      q('The Champions League was formerly known as what?', ['UEFA Cup', 'European Cup', 'Cup Winners Cup', 'Inter Cup'], 1),
      q('Which club won the 2005 final in Istanbul?', ['Liverpool', 'AC Milan', 'Chelsea', 'Arsenal'], 0),
      q('Which team won the 1999 final with two late goals?', ['Bayern Munich', 'Juventus', 'Manchester United', 'Ajax'], 2),
      q('Which city hosted the 2012 final?', ['Munich', 'London', 'Madrid', 'Rome'], 0),
    ],
  },
  {
    title: 'Classic Football Moments',
    category: 'history',
    questions: [
      q('Which nation won Euro 2004?', ['Portugal', 'Greece', 'Spain', 'France'], 1),
      q('Which country won the 2010 World Cup?', ['Netherlands', 'Germany', 'Spain', 'Brazil'], 2),
      q('Who scored the winning goal in the 2014 World Cup final?', ['Mario Gotze', 'Thomas Muller', 'Klose', 'Ozil'], 0),
      q('Which team completed the 2008-09 treble under Guardiola?', ['Barcelona', 'Inter', 'Bayern', 'Chelsea'], 0),
      q('Which country won the first UEFA European Championship?', ['Spain', 'Soviet Union', 'Italy', 'France'], 1),
    ],
  },
  {
    title: 'Premier League Clubs',
    category: 'teams',
    questions: [
      q('Which club plays at Anfield?', ['Everton', 'Liverpool', 'Arsenal', 'Chelsea'], 1),
      q('Which club is known as the Red Devils?', ['Manchester United', 'Arsenal', 'Liverpool', 'Brentford'], 0),
      q('Which team won the Premier League in 2015-16?', ['Chelsea', 'Leicester City', 'Tottenham', 'Arsenal'], 1),
      q('Which club plays at the Emirates Stadium?', ['Arsenal', 'West Ham', 'Tottenham', 'Fulham'], 0),
      q('Which club is nicknamed the Toffees?', ['Everton', 'Newcastle', 'Burnley', 'Aston Villa'], 0),
    ],
  },
  {
    title: 'European Giants',
    category: 'teams',
    questions: [
      q('Which club plays at Camp Nou?', ['Real Madrid', 'Barcelona', 'Atletico Madrid', 'Valencia'], 1),
      q('Which Italian club is called the Old Lady?', ['Inter', 'Milan', 'Juventus', 'Napoli'], 2),
      q('Which German club plays at Allianz Arena?', ['Dortmund', 'Bayern Munich', 'Leipzig', 'Leverkusen'], 1),
      q('Which French club is based in Paris?', ['Lyon', 'Marseille', 'PSG', 'Monaco'], 2),
      q('Which club is famous for La Decima?', ['Real Madrid', 'Barcelona', 'Ajax', 'Porto'], 0),
    ],
  },
  {
    title: 'National Teams',
    category: 'teams',
    questions: [
      q('Which national team is called A Selecao?', ['Brazil', 'Portugal', 'Spain', 'Argentina'], 0),
      q('Which country wears orange as its main color?', ['Belgium', 'Netherlands', 'Croatia', 'Denmark'], 1),
      q('Which team is known as the Three Lions?', ['Scotland', 'England', 'Wales', 'Ireland'], 1),
      q('Which country is nicknamed La Albiceleste?', ['Argentina', 'Uruguay', 'Chile', 'Paraguay'], 0),
      q('Which country won Euro 2020?', ['England', 'Spain', 'Italy', 'France'], 2),
    ],
  },
  {
    title: 'Legendary Players',
    category: 'players',
    questions: [
      q('Who is widely known as O Rei?', ['Pele', 'Maradona', 'Ronaldo', 'Ronaldinho'], 0),
      q('Which player won the 1998 Ballon d Or?', ['Zidane', 'Rivaldo', 'Figo', 'Ronaldo'], 0),
      q('Which goalkeeper was known as the Black Spider?', ['Buffon', 'Yashin', 'Casillas', 'Kahn'], 1),
      q('Who captained Italy to the 2006 World Cup?', ['Totti', 'Cannavaro', 'Pirlo', 'Del Piero'], 1),
      q('Which player was nicknamed Der Kaiser?', ['Beckenbauer', 'Matthaus', 'Muller', 'Klinsmann'], 0),
    ],
  },
  {
    title: 'Modern Stars',
    category: 'players',
    questions: [
      q('Which country does Kylian Mbappe represent?', ['Belgium', 'France', 'Senegal', 'Spain'], 1),
      q('Which player is associated with the SIUU celebration?', ['Messi', 'Neymar', 'Cristiano Ronaldo', 'Haaland'], 2),
      q('Which club did Erling Haaland join in 2022?', ['Real Madrid', 'Manchester City', 'Chelsea', 'PSG'], 1),
      q('Which player is known for playing as a false nine at Barca?', ['Messi', 'Busquets', 'Pique', 'Alba'], 0),
      q('Which country does Luka Modric represent?', ['Serbia', 'Croatia', 'Slovenia', 'Bosnia'], 1),
    ],
  },
  {
    title: 'Ballon d Or Winners',
    category: 'players',
    questions: [
      q('Who won the 2007 Ballon d Or?', ['Kaka', 'Messi', 'Ronaldo', 'Ronaldinho'], 0),
      q('Who won the 2018 Ballon d Or?', ['Modric', 'Ronaldo', 'Messi', 'Griezmann'], 0),
      q('Which player won multiple Ballon d Ors with Barcelona?', ['Xavi', 'Iniesta', 'Messi', 'Suarez'], 2),
      q('Who was the first African Ballon d Or winner?', ['Drogba', 'Eto o', 'George Weah', 'Mane'], 2),
      q('Which Portuguese player won the Ballon d Or in 2000?', ['Rui Costa', 'Luis Figo', 'Deco', 'Nani'], 1),
    ],
  },
  {
    title: 'Player Positions',
    category: 'players',
    questions: [
      q('What is the main job of a goalkeeper?', ['Score goals', 'Stop shots', 'Take corners', 'Press high'], 1),
      q('Which role usually leads the attack?', ['Striker', 'Center-back', 'Goalkeeper', 'Full-back'], 0),
      q('Which position often plays on the side of defense?', ['Winger', 'Full-back', 'Striker', 'Number ten'], 1),
      q('What is a playmaker usually responsible for?', ['Creating chances', 'Goalkeeping', 'Marking posts', 'Throw-ins'], 0),
      q('Which position commonly uses crosses from wide areas?', ['Winger', 'Goalkeeper', 'Center-back', 'Defensive mid'], 0),
    ],
  },
];

async function seed() {
  let inserted = 0;
  let migrated = 0;

  const existingQuizzes = await db.collection('quizzes').get();
  for (const doc of existingQuizzes.docs) {
    const data = doc.data();
    if (!Object.prototype.hasOwnProperty.call(data, 'category')) {
      await doc.ref.update({ category: 'history' });
      migrated += 1;
      console.log(`Migrated missing category: ${data.title || doc.id}`);
    }
  }

  for (const quiz of quizzes) {
    const existing = await db
      .collection('quizzes')
      .where('title', '==', quiz.title)
      .limit(1)
      .get();

    if (!existing.empty) {
      console.log(`Skipped existing quiz: ${quiz.title}`);
      continue;
    }

    await db.collection('quizzes').add({
      ...quiz,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    inserted += 1;
    console.log(`Inserted quiz: ${quiz.title}`);
  }

  console.log(`Done. Inserted ${inserted} quizzes. Migrated ${migrated} old quizzes.`);
}

seed()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

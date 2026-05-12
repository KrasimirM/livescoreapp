import '../Models/QuizCategory.dart';

final List<Map<String, dynamic>> sampleQuizzes = [
  {
    'title': 'World Cup Origins',
    'category': QuizCategory.history,
    'questions': [
      {
        'question': 'Which country hosted the first FIFA World Cup?',
        'answers': ['Uruguay', 'Brazil', 'Italy', 'France'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'In which year was the first FIFA World Cup held?',
        'answers': ['1926', '1930', '1934', '1938'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Which country won the 1966 FIFA World Cup?',
        'answers': ['England', 'Germany', 'Brazil', 'Argentina'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Who is known for the Hand of God goal?',
        'answers': ['Pele', 'Diego Maradona', 'Zinedine Zidane', 'Ronaldo'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Which country has won the most World Cups?',
        'answers': ['Germany', 'Argentina', 'Brazil', 'Italy'],
        'correctAnswerIndex': 2,
      },
    ],
  },
  {
    'title': 'Champions League History',
    'category': QuizCategory.history,
    'questions': [
      {
        'question': 'Which club has won the most Champions League titles?',
        'answers': ['AC Milan', 'Liverpool', 'Real Madrid', 'Barcelona'],
        'correctAnswerIndex': 2,
      },
      {
        'question': 'The Champions League was formerly known as what?',
        'answers': ['UEFA Cup', 'European Cup', 'Cup Winners Cup', 'Inter Cup'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Which club won the 2005 final in Istanbul?',
        'answers': ['Liverpool', 'AC Milan', 'Chelsea', 'Arsenal'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Which team won the 1999 final with two late goals?',
        'answers': ['Bayern Munich', 'Juventus', 'Manchester United', 'Ajax'],
        'correctAnswerIndex': 2,
      },
      {
        'question': 'Which city hosted the 2012 final?',
        'answers': ['Munich', 'London', 'Madrid', 'Rome'],
        'correctAnswerIndex': 0,
      },
    ],
  },
  {
    'title': 'Classic Football Moments',
    'category': QuizCategory.history,
    'questions': [
      {
        'question': 'Which nation won Euro 2004?',
        'answers': ['Portugal', 'Greece', 'Spain', 'France'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Which country won the 2010 World Cup?',
        'answers': ['Netherlands', 'Germany', 'Spain', 'Brazil'],
        'correctAnswerIndex': 2,
      },
      {
        'question': 'Who scored the winning goal in the 2014 World Cup final?',
        'answers': ['Mario Gotze', 'Thomas Muller', 'Klose', 'Ozil'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Which team completed the 2008-09 treble under Guardiola?',
        'answers': ['Barcelona', 'Inter', 'Bayern', 'Chelsea'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Which country won the first UEFA European Championship?',
        'answers': ['Spain', 'Soviet Union', 'Italy', 'France'],
        'correctAnswerIndex': 1,
      },
    ],
  },
  {
    'title': 'Premier League Clubs',
    'category': QuizCategory.teams,
    'questions': [
      {
        'question': 'Which club plays at Anfield?',
        'answers': ['Everton', 'Liverpool', 'Arsenal', 'Chelsea'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Which club is known as the Red Devils?',
        'answers': ['Manchester United', 'Arsenal', 'Liverpool', 'Brentford'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Which team won the Premier League in 2015-16?',
        'answers': ['Chelsea', 'Leicester City', 'Tottenham', 'Arsenal'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Which club plays at the Emirates Stadium?',
        'answers': ['Arsenal', 'West Ham', 'Tottenham', 'Fulham'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Which club is nicknamed the Toffees?',
        'answers': ['Everton', 'Newcastle', 'Burnley', 'Aston Villa'],
        'correctAnswerIndex': 0,
      },
    ],
  },
  {
    'title': 'European Giants',
    'category': QuizCategory.teams,
    'questions': [
      {
        'question': 'Which club plays at Camp Nou?',
        'answers': ['Real Madrid', 'Barcelona', 'Atletico Madrid', 'Valencia'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Which Italian club is called the Old Lady?',
        'answers': ['Inter', 'Milan', 'Juventus', 'Napoli'],
        'correctAnswerIndex': 2,
      },
      {
        'question': 'Which German club plays at Allianz Arena?',
        'answers': ['Dortmund', 'Bayern Munich', 'Leipzig', 'Leverkusen'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Which French club is based in Paris?',
        'answers': ['Lyon', 'Marseille', 'PSG', 'Monaco'],
        'correctAnswerIndex': 2,
      },
      {
        'question': 'Which club is famous for La Decima?',
        'answers': ['Real Madrid', 'Barcelona', 'Ajax', 'Porto'],
        'correctAnswerIndex': 0,
      },
    ],
  },
  {
    'title': 'National Teams',
    'category': QuizCategory.teams,
    'questions': [
      {
        'question': 'Which national team is called A Selecao?',
        'answers': ['Brazil', 'Portugal', 'Spain', 'Argentina'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Which country wears orange as its main color?',
        'answers': ['Belgium', 'Netherlands', 'Croatia', 'Denmark'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Which team is known as the Three Lions?',
        'answers': ['Scotland', 'England', 'Wales', 'Ireland'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Which country is nicknamed La Albiceleste?',
        'answers': ['Argentina', 'Uruguay', 'Chile', 'Paraguay'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Which country won Euro 2020?',
        'answers': ['England', 'Spain', 'Italy', 'France'],
        'correctAnswerIndex': 2,
      },
    ],
  },
  {
    'title': 'Legendary Players',
    'category': QuizCategory.players,
    'questions': [
      {
        'question': 'Who is widely known as O Rei?',
        'answers': ['Pele', 'Maradona', 'Ronaldo', 'Ronaldinho'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Which player won the 1998 Ballon d Or?',
        'answers': ['Zidane', 'Rivaldo', 'Figo', 'Ronaldo'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Which goalkeeper was known as the Black Spider?',
        'answers': ['Buffon', 'Yashin', 'Casillas', 'Kahn'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Who captained Italy to the 2006 World Cup?',
        'answers': ['Totti', 'Cannavaro', 'Pirlo', 'Del Piero'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Which player was nicknamed Der Kaiser?',
        'answers': ['Beckenbauer', 'Matthaus', 'Muller', 'Klinsmann'],
        'correctAnswerIndex': 0,
      },
    ],
  },
  {
    'title': 'Modern Stars',
    'category': QuizCategory.players,
    'questions': [
      {
        'question': 'Which country does Kylian Mbappe represent?',
        'answers': ['Belgium', 'France', 'Senegal', 'Spain'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Which player is associated with the SIUU celebration?',
        'answers': ['Messi', 'Neymar', 'Cristiano Ronaldo', 'Haaland'],
        'correctAnswerIndex': 2,
      },
      {
        'question': 'Which club did Erling Haaland join in 2022?',
        'answers': ['Real Madrid', 'Manchester City', 'Chelsea', 'PSG'],
        'correctAnswerIndex': 1,
      },
      {
        'question':
            'Which player is known for playing as a false nine at Barca?',
        'answers': ['Messi', 'Busquets', 'Pique', 'Alba'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Which country does Luka Modric represent?',
        'answers': ['Serbia', 'Croatia', 'Slovenia', 'Bosnia'],
        'correctAnswerIndex': 1,
      },
    ],
  },
  {
    'title': 'Ballon d Or Winners',
    'category': QuizCategory.players,
    'questions': [
      {
        'question': 'Who won the 2007 Ballon d Or?',
        'answers': ['Kaka', 'Messi', 'Ronaldo', 'Ronaldinho'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Who won the 2018 Ballon d Or?',
        'answers': ['Modric', 'Ronaldo', 'Messi', 'Griezmann'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Which player won multiple Ballon d Ors with Barcelona?',
        'answers': ['Xavi', 'Iniesta', 'Messi', 'Suarez'],
        'correctAnswerIndex': 2,
      },
      {
        'question': 'Who was the first African Ballon d Or winner?',
        'answers': ['Drogba', 'Eto o', 'George Weah', 'Mane'],
        'correctAnswerIndex': 2,
      },
      {
        'question': 'Which Portuguese player won the Ballon d Or in 2000?',
        'answers': ['Rui Costa', 'Luis Figo', 'Deco', 'Nani'],
        'correctAnswerIndex': 1,
      },
    ],
  },
  {
    'title': 'Player Positions',
    'category': QuizCategory.players,
    'questions': [
      {
        'question': 'What is the main job of a goalkeeper?',
        'answers': ['Score goals', 'Stop shots', 'Take corners', 'Press high'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'Which role usually leads the attack?',
        'answers': ['Striker', 'Center-back', 'Goalkeeper', 'Full-back'],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Which position often plays on the side of defense?',
        'answers': ['Winger', 'Full-back', 'Striker', 'Number ten'],
        'correctAnswerIndex': 1,
      },
      {
        'question': 'What is a playmaker usually responsible for?',
        'answers': [
          'Creating chances',
          'Goalkeeping',
          'Marking posts',
          'Throw-ins'
        ],
        'correctAnswerIndex': 0,
      },
      {
        'question': 'Which position commonly uses crosses from wide areas?',
        'answers': ['Winger', 'Goalkeeper', 'Center-back', 'Defensive mid'],
        'correctAnswerIndex': 0,
      },
    ],
  },
];

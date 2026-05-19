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

      q('Which country won the 1998 FIFA World Cup?', ['Brazil', 'France', 'Italy', 'Germany'], 1),
      q('Who scored twice in the 2002 World Cup final?', ['Rivaldo', 'Ronaldinho', 'Ronaldo', 'Kaka'], 2),
      q('Which country hosted the 2018 FIFA World Cup?', ['Germany', 'Russia', 'Qatar', 'South Africa'], 1),
      q('Who won the Golden Ball at the 2014 World Cup?', ['Messi', 'Muller', 'Neymar', 'Robben'], 0),
      q('Which country lost the 2022 World Cup final?', ['France', 'Croatia', 'Argentina', 'Morocco'], 0),
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

      q('Which club won the 2023 Champions League?', ['Inter', 'Manchester City', 'Real Madrid', 'Bayern Munich'], 1),
      q('Who scored the bicycle kick against Juventus in 2018?', ['Bale', 'Ronaldo', 'Benzema', 'Modric'], 1),
      q('Which manager won three consecutive Champions Leagues with Real Madrid?', ['Ancelotti', 'Mourinho', 'Zidane', 'Del Bosque'], 2),
      q('Which English club won the 2012 Champions League?', ['Manchester United', 'Liverpool', 'Chelsea', 'Arsenal'], 2),
      q('Which stadium hosted the 2024 Champions League final?', ['Wembley', 'San Siro', 'Allianz Arena', 'Bernabeu'], 0),
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

      q('Which player headbutted Materazzi in the 2006 World Cup final?', ['Henry', 'Zidane', 'Vieira', 'Trezeguet'], 1),
      q('Which club completed an unbeaten Premier League season in 2003-04?', ['Chelsea', 'Manchester United', 'Arsenal', 'Liverpool'], 2),
      q('Which country won Euro 2016?', ['France', 'Portugal', 'Germany', 'Spain'], 1),
      q('Who scored the winning goal in the Euro 2016 final?', ['Ronaldo', 'Nani', 'Eder', 'Pepe'], 2),
      q('Which club won the 2010 treble under Jose Mourinho?', ['Inter', 'Barcelona', 'Chelsea', 'Bayern Munich'], 0),
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

      q('Which club is known as The Citizens?', ['Manchester City', 'Chelsea', 'Arsenal', 'Newcastle'], 0),
      q('Which club plays at Old Trafford?', ['Liverpool', 'Manchester United', 'Everton', 'Chelsea'], 1),
      q('Which London club plays at Stamford Bridge?', ['Arsenal', 'Tottenham', 'Chelsea', 'West Ham'], 2),
      q('Which club won the Premier League in 2022-23?', ['Arsenal', 'Manchester City', 'Liverpool', 'Newcastle'], 1),
      q('Which club is nicknamed The Magpies?', ['Burnley', 'Fulham', 'Newcastle United', 'Leeds'], 2),
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

      q('Which club plays at the Santiago Bernabeu?', ['Sevilla', 'Barcelona', 'Real Madrid', 'Valencia'], 2),
      q('Which club won the Bundesliga in 2024?', ['Bayern Munich', 'Leverkusen', 'Dortmund', 'Leipzig'], 1),
      q('Which Italian club shares San Siro with Inter?', ['Roma', 'Napoli', 'Milan', 'Lazio'], 2),
      q('Which Portuguese club is based in Lisbon?', ['Porto', 'Benfica', 'Braga', 'Sporting Gijon'], 1),
      q('Which Dutch club is famous for its academy and Total Football?', ['PSV', 'Feyenoord', 'Ajax', 'AZ Alkmaar'], 2),
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

      q('Which country won Copa America 2021?', ['Brazil', 'Argentina', 'Uruguay', 'Chile'], 1),
      q('Which national team is known as the Samurai Blue?', ['Japan', 'South Korea', 'China', 'Thailand'], 0),
      q('Which African nation reached the 2022 World Cup semi-finals?', ['Nigeria', 'Egypt', 'Morocco', 'Senegal'], 2),
      q('Which country hosted Euro 2016?', ['Germany', 'France', 'Portugal', 'Italy'], 1),
      q('Which country won the 2023 Women’s World Cup?', ['Spain', 'England', 'USA', 'Germany'], 0),
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

      q('Which player is known as El Fenomeno?', ['Ronaldinho', 'Ronaldo Nazario', 'Romario', 'Neymar'], 1),
      q('Which player spent most of his career at Roma?', ['Pirlo', 'Totti', 'Gattuso', 'Nesta'], 1),
      q('Which Croatian player won the Ballon d Or in 2018?', ['Rakitic', 'Perisic', 'Modric', 'Mandzukic'], 2),
      q('Who became Manchester United’s youngest Premier League scorer?', ['Rooney', 'Rashford', 'Greenwood', 'Martial'], 0),
      q('Which Brazilian was famous for the elastico skill move?', ['Kaka', 'Ronaldinho', 'Rivelino', 'Neymar'], 1),
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

      q('Which club did Lionel Messi join in 2023?', ['Barcelona', 'Inter Miami', 'PSG', 'Al Nassr'], 1),
      q('Which Saudi club signed Cristiano Ronaldo?', ['Al Hilal', 'Al Nassr', 'Al Ittihad', 'Al Ahli'], 1),
      q('Which English player joined Real Madrid in 2023?', ['Foden', 'Rice', 'Bellingham', 'Saka'], 2),
      q('Which player won the Golden Boot at the 2022 World Cup?', ['Messi', 'Mbappe', 'Giroud', 'Alvarez'], 1),
      q('Which Norwegian striker plays for Manchester City?', ['Odegaard', 'Haaland', 'Sorloth', 'Ajer'], 1),
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

      q('Who won the Ballon d Or in 2021?', ['Lewandowski', 'Messi', 'Jorginho', 'Benzema'], 1),
      q('Which player won the Ballon d Or in 2022?', ['Mbappe', 'Benzema', 'Messi', 'Haaland'], 1),
      q('Which club was Cristiano Ronaldo playing for when he won his first Ballon d Or?', ['Real Madrid', 'Manchester United', 'Juventus', 'Sporting'], 1),
      q('Who won the Ballon d Or before Messi and Ronaldo dominance in 2006?', ['Cannavaro', 'Kaka', 'Ronaldinho', 'Henry'], 0),
      q('Which Dutch player won three Ballon d Or awards?', ['Cruyff', 'Van Basten', 'Gullit', 'Rijkaard'], 0),
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

      q('Which position usually wears the number 1 shirt?', ['Striker', 'Midfielder', 'Goalkeeper', 'Defender'], 2),
      q('Which player role focuses on breaking up attacks?', ['Winger', 'Defensive midfielder', 'Striker', 'Second striker'], 1),
      q('Which position is closest to the opponent goal most of the time?', ['Center-back', 'Goalkeeper', 'Striker', 'Full-back'], 2),
      q('What is the main task of a center-back?', ['Score penalties', 'Defend central areas', 'Take corners', 'Play on the wing'], 1),
      q('Which role often provides assists from the wings?', ['Winger', 'Goalkeeper', 'Sweeper', 'Center-back'], 0),
    ],
  },
  {
    title: 'World Cup Drama',
    category: 'history',
    questions: [
      q('Which country famously defeated Brazil 7-1 in 2014?', ['Argentina', 'Germany', 'Netherlands', 'France'], 1),
      q('Who scored the winning penalty in the 2006 World Cup final shootout for Italy?', ['Pirlo', 'Totti', 'Grosso', 'Del Piero'], 2),
      q('Which country hosted the 2010 FIFA World Cup?', ['Brazil', 'Germany', 'South Africa', 'Japan'], 2),
      q('Which player won the Golden Boot at the 2006 World Cup?', ['Klose', 'Henry', 'Ronaldo', 'Cannavaro'], 0),
      q('Which nation won the first ever Women’s World Cup?', ['Germany', 'USA', 'Norway', 'Brazil'], 1),
    ],
  },
  {
    title: 'Historic Finals',
    category: 'history',
    questions: [
      q('Which club won the first Champions League era final in 1993?', ['Marseille', 'Milan', 'Barcelona', 'Ajax'], 0),
      q('Who scored the winning goal for Barcelona in the 2009 Champions League final?', ['Messi', 'Eto o', 'Xavi', 'Henry'], 0),
      q('Which club completed La Remontada against PSG in 2017?', ['Real Madrid', 'Chelsea', 'Barcelona', 'Bayern Munich'], 2),
      q('Which team defeated Atletico Madrid in the 2014 Champions League final?', ['Chelsea', 'Real Madrid', 'Bayern Munich', 'Liverpool'], 1),
      q('Which goalkeeper saved a penalty in the 2005 Champions League final shootout?', ['Casillas', 'Buffon', 'Dudek', 'Cech'], 2),
    ],
  },
  {
    title: 'Football Rivalries',
    category: 'history',
    questions: [
      q('What is the name of the rivalry between Barcelona and Real Madrid?', ['Der Klassiker', 'El Clasico', 'Old Firm', 'Super Derby'], 1),
      q('Which two clubs contest the Manchester Derby?', ['United and Liverpool', 'United and City', 'City and Leeds', 'United and Everton'], 1),
      q('Which Scottish clubs play in the Old Firm derby?', ['Hearts and Hibs', 'Celtic and Rangers', 'Aberdeen and Celtic', 'Rangers and Dundee'], 1),
      q('Which Italian derby is played between Inter and Juventus?', ['Derby della Madonnina', 'Derby d Italia', 'Rome Derby', 'Turin Derby'], 1),
      q('Which derby is contested by Boca Juniors and River Plate?', ['El Clasico', 'Superclasico', 'Copa Derby', 'Buenos Derby'], 1),
    ],
  },
  {
    title: 'Premier League Legends',
    category: 'teams',
    questions: [
      q('Which club did Thierry Henry become a legend at?', ['Chelsea', 'Arsenal', 'Liverpool', 'Manchester United'], 1),
      q('Which Premier League club is based at Etihad Stadium?', ['Manchester City', 'Everton', 'West Ham', 'Newcastle'], 0),
      q('Which club won the first Premier League season in 1992-93?', ['Arsenal', 'Liverpool', 'Manchester United', 'Blackburn'], 2),
      q('Which club is known as the Hammers?', ['Leeds', 'West Ham', 'Burnley', 'Everton'], 1),
      q('Which team famously went unbeaten in the 2003-04 Premier League season?', ['Chelsea', 'Manchester United', 'Liverpool', 'Arsenal'], 3),
    ],
  },
  {
    title: 'European Powerhouses',
    category: 'teams',
    questions: [
      q('Which club is nicknamed Los Blancos?', ['Barcelona', 'Sevilla', 'Real Madrid', 'Valencia'], 2),
      q('Which club won the treble in 2013 under Jupp Heynckes?', ['Bayern Munich', 'Dortmund', 'Inter', 'Juventus'], 0),
      q('Which club is based in Turin?', ['Roma', 'Milan', 'Juventus', 'Napoli'], 2),
      q('Which Portuguese club has an eagle as its symbol?', ['Porto', 'Benfica', 'Sporting', 'Braga'], 1),
      q('Which club won the Europa League in 2022?', ['Roma', 'Sevilla', 'Frankfurt', 'West Ham'], 2),
    ],
  },
  {
    title: 'International Glory',
    category: 'teams',
    questions: [
      q('Which country won the 2014 FIFA World Cup?', ['Argentina', 'Germany', 'Brazil', 'Spain'], 1),
      q('Which country won the 2022 Copa America?', ['Brazil', 'Argentina', 'Uruguay', 'Chile'], 1),
      q('Which national team is nicknamed the Azzurri?', ['France', 'Italy', 'Portugal', 'Spain'], 1),
      q('Which country won the UEFA Nations League in 2019?', ['Portugal', 'France', 'Spain', 'Italy'], 0),
      q('Which country hosted the 2022 FIFA World Cup?', ['USA', 'Russia', 'Qatar', 'China'], 2),
    ],
  },
  {
    title: 'Football Superstars',
    category: 'players',
    questions: [
      q('Which player is famous for the quote "I came, I saw, I conquered"?', ['Ibrahimovic', 'Cantona', 'Ronaldo', 'Rooney'], 0),
      q('Which player won the World Cup with both Brazil and Barcelona legend status?', ['Rivaldo', 'Romario', 'Ronaldinho', 'Neymar'], 2),
      q('Which player was known as Captain Fantastic at Liverpool?', ['Gerrard', 'Carragher', 'Torres', 'Suarez'], 0),
      q('Which French player won the Ballon d Or in 2022?', ['Mbappe', 'Benzema', 'Griezmann', 'Henry'], 1),
      q('Which player scored the fastest hat-trick in Premier League history?', ['Aguero', 'Mane', 'Salah', 'Kane'], 1),
    ],
  },
  {
    title: 'Rising Stars',
    category: 'players',
    questions: [
      q('Which club does Vinicius Junior play for?', ['PSG', 'Barcelona', 'Real Madrid', 'Liverpool'], 2),
      q('Which English midfielder joined Bayern Munich in 2023?', ['Bellingham', 'Rice', 'Kane', 'Dier'], 3),
      q('Which player won the Golden Boy award in 2023?', ['Bellingham', 'Musiala', 'Yamal', 'Balde'], 0),
      q('Which country does Jamal Musiala represent internationally?', ['England', 'Germany', 'France', 'Austria'], 1),
      q('Which player is nicknamed The Norwegian Robot?', ['Odegaard', 'Haaland', 'Nunez', 'Isak'], 1),
    ],
  },
  {
    title: 'Golden Boot Heroes',
    category: 'players',
    questions: [
      q('Who won the Golden Boot at the 2018 World Cup?', ['Mbappe', 'Kane', 'Lukaku', 'Griezmann'], 1),
      q('Which striker scored 5 goals in one Champions League match for Barcelona?', ['Messi', 'Suarez', 'Villa', 'Neymar'], 0),
      q('Who is the all-time top scorer in Champions League history?', ['Messi', 'Lewandowski', 'Ronaldo', 'Benzema'], 2),
      q('Which player won the Premier League Golden Boot in 2022-23?', ['Salah', 'Kane', 'Haaland', 'Rashford'], 2),
      q('Which Polish striker starred for Bayern Munich for many years?', ['Milik', 'Lewandowski', 'Piatek', 'Zielinski'], 1),
    ],
  },
  {
    title: 'Football Basics',
    category: 'players',
    questions: [
      q('How many minutes are added for halftime in football?', ['10', '15', '20', '5'], 1),
      q('What is it called when a player scores three goals?', ['Brace', 'Treble', 'Hat-trick', 'Combo'], 2),
      q('Which official controls the match on the field?', ['Coach', 'Captain', 'Referee', 'Manager'], 2),
      q('What happens if a knockout match is level after extra time?', ['Replay', 'Golden goal', 'Penalty shootout', 'Coin toss'], 2),
      q('Which part of the body cannot intentionally touch the ball for outfield players?', ['Head', 'Chest', 'Hand', 'Knee'], 2),
    ],
  },
  {
    title: 'Iconic Managers',
    category: 'players',
    questions: [
      q('Which manager was famous for tiki-taka football at Barcelona?', ['Mourinho', 'Guardiola', 'Klopp', 'Ancelotti'], 1),
      q('Which manager led Leicester City to the 2015-16 Premier League title?', ['Ranieri', 'Conte', 'Rodgers', 'Puel'], 0),
      q('Which manager is known as The Special One?', ['Ancelotti', 'Klopp', 'Mourinho', 'Ferguson'], 2),
      q('Which legendary manager coached Manchester United for over 20 years?', ['Wenger', 'Ferguson', 'Busby', 'Ten Hag'], 1),
      q('Which German manager introduced heavy metal football at Liverpool?', ['Tuchel', 'Nagelsmann', 'Klopp', 'Flick'], 2),
    ],
  },
  {
    title: 'Football Records',
    category: 'players',
    questions: [
      q('Which player has won the most Ballon d Or awards?', ['Ronaldo', 'Messi', 'Cruyff', 'Platini'], 1),
      q('Which country has appeared in the most World Cup finals?', ['Germany', 'Brazil', 'Italy', 'Argentina'], 0),
      q('Which player has the most international goals?', ['Messi', 'Ali Daei', 'Ronaldo', 'Puskas'], 2),
      q('Which club has won the most Premier League titles?', ['Liverpool', 'Chelsea', 'Manchester United', 'Arsenal'], 2),
      q('Which goalkeeper has the most clean sheets in Premier League history?', ['Cech', 'Schmeichel', 'Alisson', 'De Gea'], 0),
    ],
  },
  {
    title: 'Tactical Football',
    category: 'players',
    questions: [
      q('Which formation uses three defenders and five midfielders?', ['4-4-2', '3-5-2', '4-3-3', '5-4-1'], 1),
      q('What is pressing in football?', ['Defending deep', 'Quick attacking', 'Applying pressure to win the ball', 'Crossing often'], 2),
      q('Which role often sits in front of the defense?', ['Target man', 'Defensive midfielder', 'Winger', 'Second striker'], 1),
      q('What is counter-attacking football based on?', ['Slow possession', 'Quick transitions', 'Long throw-ins', 'High crosses'], 1),
      q('Which position usually dictates the tempo of the game?', ['Goalkeeper', 'Playmaker', 'Center-back', 'Full-back'], 1),
    ],
  },
  {
    title: 'Famous Stadiums',
    category: 'teams',
    questions: [
      q('Which stadium is home to Bayern Munich?', ['Signal Iduna Park', 'Allianz Arena', 'San Siro', 'Olympiastadion'], 1),
      q('Which stadium hosted the 2022 World Cup final?', ['Lusail Stadium', 'Al Bayt Stadium', '974 Stadium', 'Education City'], 0),
      q('Which club plays at Signal Iduna Park?', ['Bayern Munich', 'RB Leipzig', 'Borussia Dortmund', 'Schalke'], 2),
      q('Which stadium is known as the Theatre of Dreams?', ['Anfield', 'Old Trafford', 'Wembley', 'Camp Nou'], 1),
      q('Which Italian stadium is home to Roma?', ['San Siro', 'Stadio Olimpico', 'Juventus Stadium', 'Maradona Stadium'], 1),
    ],
  },
  {
    title: 'Underdog Stories',
    category: 'history',
    questions: [
      q('Which country shocked the world by winning Euro 2004?', ['Turkey', 'Portugal', 'Greece', 'Czech Republic'], 2),
      q('Which club won the Premier League despite 5000-1 odds?', ['Blackburn', 'Leicester City', 'Leeds United', 'Newcastle'], 1),
      q('Which African country reached the 2010 World Cup quarter-finals?', ['Ghana', 'Nigeria', 'Cameroon', 'Algeria'], 0),
      q('Which club eliminated Barcelona after losing 3-0 in the first leg in 2019?', ['Liverpool', 'Roma', 'Chelsea', 'PSG'], 0),
      q('Which team won Euro 1992 after entering the tournament late?', ['Denmark', 'Sweden', 'Germany', 'Netherlands'], 0),
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

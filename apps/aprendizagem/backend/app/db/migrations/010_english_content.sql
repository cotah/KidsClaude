-- 010_english_content.sql
-- Adiciona versao em ingles dos titulos, content_blocks e challenges
-- das 16 licoes regulares. Cria 4 colunas opcionais (PT continua sendo
-- o default). Frontend pode escolher o idioma com base na preferencia
-- do usuario quando esse seletor for adicionado.
--
-- Idempotencia: ALTER usa IF NOT EXISTS; UPDATEs sao deterministicos
-- (mesma entrada = mesma saida). Gate no run_migrations.sh detecta a
-- existencia de lessons.title_en pra pular re-execucao.
--
-- Tudo dentro de BEGIN/COMMIT: se qualquer UPDATE falhar (ex: slug nao
-- existe), rollback derruba ate' o ALTER, deixando a tabela como antes.

BEGIN;

ALTER TABLE lessons ADD COLUMN IF NOT EXISTS title_en TEXT;
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS content_blocks_en JSONB;
ALTER TABLE challenges ADD COLUMN IF NOT EXISTS question_en TEXT;
ALTER TABLE challenges ADD COLUMN IF NOT EXISTS options_en JSONB;

-- ============================================================
-- LESSONS: title_en + content_blocks_en (16 UPDATEs)
-- ============================================================
-- Slugs encurtados na requisicao mapeados aos slugs reais do DB
-- (validados contra migration 005).

UPDATE lessons SET
  title_en = 'What is Artificial Intelligence?',
  content_blocks_en = $blocks$[
    {"type":"text","content":"Have you ever played with a toy that seemed to think on its own? Like a car that avoids walls, or a doll that talks when you press its belly? Artificial Intelligence — which we call AI — is similar to that, but way, way smarter! It's a computer that learned to think by reading billions of words, stories, and conversations. Imagine reading every single book in your school library at the same time. AI did exactly that, but with books from the entire world!"},
    {"type":"text","content":"Have you noticed that when you watch a cartoon on YouTube, it keeps suggesting other cartoons you love? That's AI working! Or when you type a word on a phone and it already suggests the next one? AI again! It learns the same way you learn to build a LEGO set: trying, making mistakes, trying again, until it gets it just right."},
    {"type":"text","content":"AI is not a monster or an evil robot from a movie. It doesn't have a body or feelings. It's more like a giant, super-smart book that learned how to answer questions. The term \"Artificial Intelligence\" was invented back in 1956 — way before the internet, tablets, or YouTube even existed!"}
  ]$blocks$::jsonb
WHERE slug = 's1-o-que-e-ia';

UPDATE lessons SET
  title_en = 'Who is Claude?',
  content_blocks_en = $blocks$[
    {"type":"text","content":"Claude is a super-intelligent computer friend! She was created by a team of scientists called Anthropic — people who work every single day to make AI as safe and as kind as possible. It's like they're the creators of a cartoon character, except this character actually talks back to you in real life!"},
    {"type":"text","content":"Claude has three amazing superpowers. First: she understands any question, even the really hard ones! Second: she writes stories, poems, riddles, and so much more. Third: she explains things in a way that you can actually understand, like the coolest teacher ever. She's kind of like Hermione Granger, but in computer form!"},
    {"type":"text","content":"One very special thing about Claude: she never makes up answers. If she doesn't know something, she honestly says \"I don't know.\" That's rare and really important! You can trust what she says because she's honest, just like a true good friend."}
  ]$blocks$::jsonb
WHERE slug = 's1-quem-e-claude';

UPDATE lessons SET
  title_en = 'How to Talk to Claude',
  content_blocks_en = $blocks$[
    {"type":"text","content":"Talking to Claude is as easy as sending a message to a friend! You type what you want and she responds. But there's a magic secret to getting even more amazing answers. This secret has a special name: Prompt. A prompt is everything you write to Claude — it's your magic request!"},
    {"type":"text","content":"Think of it this way: imagine you want someone to draw your favorite character. If you just say \"draw a character,\" that person doesn't know if it should be big or small, with a cape or a sword. But if you say \"draw Pikachu using Thunderbolt, with a yellow lightning background and a big smile\" — now that's clear! With Claude it's the same: the more you explain, the more incredible the answer gets."},
    {"type":"text","content":"The golden rules are simple: be CLEAR about what you want, share a little bit of context, and say how you want the answer (short story? a list? a simple explanation?). And if you don't understand the answer, you can ask again in a different way. Claude never gets annoyed by questions! It's like asking a smart speaker to play a song — the more specific you are, the better it gets it right."}
  ]$blocks$::jsonb
WHERE slug = 's1-como-conversar-claude';

UPDATE lessons SET
  title_en = 'Claude Tells Stories!',
  content_blocks_en = $blocks$[
    {"type":"text","content":"Claude is like one of those interactive story books where you choose the path — but even better! You come up with the characters, the setting, and the type of adventure, and Claude writes the whole story right then and there. It's like having a Disney author available just for you!"},
    {"type":"text","content":"For the best story possible, you need to put some effort into the request. Tell Claude the main character's name (it can be you!), whether it's an adventure, mystery, or comedy, where it all takes place — a magic forest? outer space? a school of wizardry? — and whether you want a happy ending or a surprise one. Claude can write like a children's book, like a fairy tale, or even like a Diary of a Wimpy Kid story!"},
    {"type":"text","content":"The coolest part: you can ask Claude to CONTINUE a story that you started yourself. You write the beginning and she finishes it! Or if the ending wasn't what you wanted, just ask for a different one. You're the director of your very own story!"}
  ]$blocks$::jsonb
WHERE slug = 's1-claude-conta-historias';

UPDATE lessons SET
  title_en = 'What is an API?',
  content_blocks_en = $blocks$[
    {"type":"text","content":"You know when you're playing Fortnite or Roblox and the server knows exactly where every player is, how much health they have, what they're carrying — all in real time? That works through APIs! API stands for Application Programming Interface, and it's basically how two programs talk to each other over the internet without you seeing what happens underneath."},
    {"type":"text","content":"Think of it like this: in Minecraft, when you open your inventory, the game fetches from memory what you're carrying and displays it on screen. When you drop something, it updates that inventory. APIs work the same way, but between different programs: an app on your phone \"requests\" data from a server on the internet, the server processes it and \"responds\" with the information. It's like sending a message on WhatsApp and getting a reply — but between programs!"},
    {"type":"text","content":"There's a super fun API called PokéAPI that has complete data on every single Pokémon, totally free! When you open the URL pokeapi.co/api/v2/pokemon/pikachu in your browser, within seconds you see all of Pikachu's data: type, height, weight, abilities, moves. It's like a live digital Pokédex! There are over 24,000 public and free APIs in the world — games, movies, music, countries, weather, all of it."}
  ]$blocks$::jsonb
WHERE slug = 's2-o-que-e-api';

UPDATE lessons SET
  title_en = 'JSON — The Language of APIs',
  content_blocks_en = $blocks$[
    {"type":"text","content":"When an API responds, it sends data in a format called JSON. It looks strange the first time, but once you understand the logic, you'll be able to read any JSON easily! Think of it like a character's stats in an RPG game: they have a name, level, health, attack — each attribute has a name and a value. JSON is exactly that, organized with keys and values."},
    {"type":"text","content":"For example, Pikachu's data in JSON looks like this: the field \"name\" has the value \"pikachu\", the field \"height\" has the value 4, the field \"weight\" has the value 60. Just like a character's stats in Pokémon GO! Each piece of information has a specific spot with a label on it. Want to know the type? Look at the \"types\" field. Want to know the abilities? Look at the \"abilities\" field. It's like the status screen in an RPG, but in text form."},
    {"type":"text","content":"In JSON you'll find 4 types of things. Text always goes inside quotes, like \"pikachu\". Numbers go without quotes, like 4 or 60. Lists go inside square brackets [ ], perfect for storing multiple items like a Pokémon's types. And objects go inside curly braces { }, like a complete character sheet. With this map, you can read any JSON from any API!"}
  ]$blocks$::jsonb
WHERE slug = 's2-json-lingua-apis';

UPDATE lessons SET
  title_en = 'Free APIs to Explore!',
  content_blocks_en = $blocks$[
    {"type":"text","content":"Did you know there's a free API for almost anything you're into? No sign-up, no credit card, just open your browser and use it. It's like free mods for the internet — anyone can access them! Here are the best ones to explore right now."},
    {"type":"text","content":"The PokéAPI (pokeapi.co) has complete data on every Pokémon, including images, moves, evolutions, and stats. The catfact.ninja/fact URL returns a random and curious fact about cats every single time you access it — great for surprising your friends with trivia! REST Countries (restcountries.com) has everything about any country: flag, capital, population, languages, time zones. JokeAPI has safe jokes in multiple languages. And Open-Meteo has real-time weather data for any city in the world, no account needed."},
    {"type":"text","content":"The coolest part: you can access these URLs directly in your browser, just like opening a regular website! Try it now — open a new tab and type: pokeapi.co/api/v2/pokemon/charizard. You'll see Charizard's complete JSON data appear on screen, just like when you open DevTools in games to see the data. Then just copy and paste that JSON into Claude — and she explains everything!"}
  ]$blocks$::jsonb
WHERE slug = 's2-apis-gratuitas';

UPDATE lessons SET
  title_en = 'Claude + APIs = Superpower!',
  content_blocks_en = $blocks$[
    {"type":"text","content":"Have you ever imagined combining real data from an API with Claude's intelligence? It's the equivalent of installing an AI mod into your favorite game — everything gets more powerful! The idea is simple: you grab raw data from an API (which looks confusing in JSON) and ask Claude to transform it into something amazing."},
    {"type":"text","content":"For example: you open the PokéAPI, grab Charizard and Blastoise's data, paste it to Claude, and ask \"based on these real stats, who would win a battle and why?\" She analyzes the actual numbers and creates an epic battle commentary! Or grab weather data from a city, paste the JSON and ask \"describe this weather like it's a video game weather report.\" You have the data — Claude has the creativity!"},
    {"type":"text","content":"This combo is exactly what the famous apps you use do all the time. YouTube fetches data from your watch history through an API and uses AI to recommend the next video. Spotify fetches data from your listening habits and uses AI to create your Weekly Discovery playlist. You're learning the foundation of what the biggest tech companies in the world use. And you're doing it at 9 or 10 years old!"}
  ]$blocks$::jsonb
WHERE slug = 's2-claude-apis-superpoder';

UPDATE lessons SET
  title_en = 'What is Code?',
  content_blocks_en = $blocks$[
    {"type":"text","content":"You know when you open Instagram and the photos load, stories appear at the top, the like button works with that heart animation — all of that was written by someone in code. Code is a set of precise instructions that a computer executes line by line. It's like a recipe the computer follows exactly, with no improvisation."},
    {"type":"text","content":"On the web, there's a holy trinity of languages you need to know. HTML defines what exists on the page: this button is here, this text goes there, this image is in this spot. CSS defines how everything looks: the button's color, the font size, the spacing between posts, the Instagram heart animation. JavaScript defines what happens when you interact with it: clicked a button? A menu opens. Scrolled down? More posts load. This is exactly how every app you use was built."},
    {"type":"text","content":"The best news of all: with Claude, you don't need to memorize syntax or spend months studying. You describe what you want in plain English and she writes the code. It's like having a senior developer available 24 hours ready to build anything you can imagine. What you need to learn is how to describe well what you want — and that's exactly what you've been practicing with prompts!"}
  ]$blocks$::jsonb
WHERE slug = 's3-o-que-e-codigo';

UPDATE lessons SET
  title_en = 'Claude Writes Code for You!',
  content_blocks_en = $blocks$[
    {"type":"text","content":"Imagine having a full-stack developer who charges nothing, never complains about hard requests, and explains every line of the code they write. That's exactly what Claude does! She writes in HTML, CSS, JavaScript, Python, SQL, and dozens of other languages. And unlike YouTube tutorials, she creates specifically what you asked for — not some generic sample project."},
    {"type":"text","content":"The secret to professional-quality results is the level of detail in your request. Instead of \"make me a website about music,\" try specifying the theme, the sections you want, the visual style, specific features, and whether it needs to work on mobile. The more you sound like a client briefing a developer, the better the result gets. It's training the muscle of communicating ideas with precision — an incredibly valuable skill."},
    {"type":"text","content":"To test everything without installing anything, there's CodePen.io — a free online editor where you paste Claude's HTML/CSS/JS and see the result live in seconds. And if something isn't quite how you imagined it? Just request a tweak: \"make the background darker,\" \"animate the button,\" \"add a contact section.\" Claude will iterate as many times as you need, without complaining."}
  ]$blocks$::jsonb
WHERE slug = 's3-claude-escreve-codigo';

UPDATE lessons SET
  title_en = 'The Perfect Website Recipe',
  content_blocks_en = $blocks$[
    {"type":"text","content":"You've probably noticed how some websites have that professional look — the right fonts, matching colors, smooth animations — while others look like they were put together carelessly. The difference isn't just the developer, it's the level of detail in the brief. With Claude, you can achieve that same level of quality — you just need to know how to ask with precision."},
    {"type":"text","content":"The recipe has 6 required ingredients. THEME: what is the website about? AUDIENCE: who is it for? (k-pop fans? gamers? followers of your page?) SECTIONS: which parts do you want? (home, about, gallery, contact?) COLORS: what visual palette? (dark mode with neon? minimalist white? vibrant and colorful?) EXTRAS: scroll animations? hover effects? interactive cards? DEVICE: does it need to work well on mobile, because most people access sites from their phones these days."},
    {"type":"text","content":"Compare: the weak request would be \"make a website about k-pop.\" The professional request would be: \"create a complete HTML/CSS/JS website for Gen Z k-pop fans. Sections: animated text hero, top 5 groups with interactive cards, embedded Spotify playlist, newsletter form. Dark mode with pink-purple neon gradient, modern sans-serif font. Fully mobile responsive. Smooth hover effects on cards.\" See what a difference that makes!"}
  ]$blocks$::jsonb
WHERE slug = 's3-receita-site-perfeito';

UPDATE lessons SET
  title_en = 'Website + API = A Real App!',
  content_blocks_en = $blocks$[
    {"type":"text","content":"You know the difference between a static website — like a digital flyer that always shows the same info — and an app like TikTok, Instagram, or Spotify? The app fetches fresh data from the internet in real time through APIs. Every time you open TikTok, it calls an API that returns the most relevant videos for you at that moment. When you search for a song on Spotify, an API queries the database and returns results in milliseconds. That's how every modern internet experience you use works."},
    {"type":"text","content":"In code, this happens with JavaScript using a function called fetch. You put in an API URL, the code \"knocks on\" the server's door, the server responds with JSON, and you use that data to update what appears on the screen — all without reloading the page. This is the technology behind every modern internet experience you use."},
    {"type":"text","content":"To apply this now: ask Claude to create a Pokémon search app where the user types a name, clicks search, and JavaScript uses fetch to call the PokéAPI and display the image, type, height, and weight. Claude writes all the code. You understand the logic. You test it on CodePen. It's a real app, with real data, that you built — even without knowing how to code from scratch!"}
  ]$blocks$::jsonb
WHERE slug = 's3-site-api-app-real';

UPDATE lessons SET
  title_en = 'What is Prompt Engineering?',
  content_blocks_en = $blocks$[
    {"type":"text","content":"Prompt Engineering is the ability to communicate with AI systems in a strategic and precise way to maximize the quality of results. In a market where AI is being integrated into virtually every field — law, medicine, marketing, engineering, design — those who know how to direct AI with mastery have a real and measurable competitive advantage."},
    {"type":"text","content":"The 5 pillars that define a competent Prompt Engineer: PERSONA (instructing the AI on the role it should take — \"you are a senior data analyst focused on e-commerce\"), CONTEXT (providing all relevant information about the situation without assuming the AI \"already knows\"), OBJECTIVE (being hyper-specific about the deliverable — not \"help me with marketing\" but \"create 5 email marketing subject lines for Black Friday focused on conversion, target audience 25-40 years old\"), FORMAT (specifying the structure of the response — table, JSON, markdown, bullet points, code), EXAMPLES (one-shot or few-shot learning — showing examples of what quality means for that specific use case)."},
    {"type":"text","content":"Prompt Engineer is one of the highest-compensated roles in the current technology market. In the US, salaries reach $175,000 per year at companies like Anthropic, OpenAI, and Google DeepMind. In the UK, Europe, and globally, demand is growing rapidly with companies across all sectors seeking professionals who know how to extract real value from AI systems. You're developing this skill now, ahead of most professionals in the market."}
  ]$blocks$::jsonb
WHERE slug = 's4-prompt-engineering';

UPDATE lessons SET
  title_en = 'Powerful vs. Weak Prompts',
  content_blocks_en = $blocks$[
    {"type":"text","content":"In the professional market, the difference between those who use AI in a mediocre way and those who extract exceptional results comes down fundamentally to prompt quality. It's not about the AI model, it's not about which platform — it's about the quality of the instruction. Companies that have realized this are creating internal \"prompt libraries\" and training their teams in advanced prompting techniques."},
    {"type":"text","content":"Compare two prompts for the same task: the weak one would be \"write a sales email.\" The professional one would be: \"write a B2B sales email to prospect CTOs at tech startups with 50-200 employees. Product: an analytics platform that reduces data analysis time by 60%. Tone: direct, data-driven, no buzzwords. Structure: hook with a market statistic, value proposition in 2 sentences, social proof with one use case, specific CTA for a 20-minute demo. Limit: 250 words.\" The results are incomparable."},
    {"type":"text","content":"The mental test that separates mediocre prompts from excellent ones: \"If I were a senior professional receiving this brief, would I have all the information needed to deliver the result without guessing anything?\" If there's any ambiguity about audience, format, tone, objective, context, or constraints — the prompt isn't finished yet. This habit improves not just your communication with AI, but all of your professional communication."}
  ]$blocks$::jsonb
WHERE slug = 's4-prompts-poderosos-vs-fracos';

UPDATE lessons SET
  title_en = 'System Prompts — Building AI Agents',
  content_blocks_en = $blocks$[
    {"type":"text","content":"A System Prompt is the instruction layer that defines an AI agent's base behavior before any user interaction. It's invisible to the end user, but it completely determines the agent's personality, constraints, domain knowledge, and response format. Every time you use a company's customer service chatbot, a specialized assistant on a platform, or an AI with a specific persona, there's a well-structured System Prompt behind it."},
    {"type":"text","content":"A professional System Prompt has clear components: IDENTITY AND PURPOSE (who the agent is, what it was created for, who the expected user is), PERSONALITY AND TONE (formal, technical, empathetic, direct, multilingual?), DOMAIN KNOWLEDGE (what topics it specializes in, what's out of scope), OPERATIONAL RULES (what it always does, what it never does, how it handles edge cases), OUTPUT FORMAT (default response structure, markdown usage, expected length). Each component has a direct impact on the end user's experience."},
    {"type":"text","content":"Companies like Duolingo, Notion, Intercom, and GitHub Copilot invest significantly in Prompt Engineering for System Prompts — it's the difference between a generic AI and an AI product with real identity and utility. Knowing how to build effective System Prompts is a competency that opens doors in product management, AI engineering, product design, and startup founding. It's one of the scarcest and most in-demand skills in the current market."}
  ]$blocks$::jsonb
WHERE slug = 's4-system-prompts';

UPDATE lessons SET
  title_en = 'Claude Code and MCP — The Future of AI',
  content_blocks_en = $blocks$[
    {"type":"text","content":"Claude Code is Claude's interface that operates directly on the local file system via terminal. Unlike the web version — which only has conversations — Claude Code acts: it reads and writes files, executes commands, installs dependencies, runs tests, makes Git commits, and builds complete projects autonomously. It's the equivalent of having a senior engineer who does the work, not just gives advice. Developers who have adopted Claude Code report productivity increases of 3x to 5x on coding tasks."},
    {"type":"text","content":"MCP — Model Context Protocol — is an open standard launched by Anthropic in 2024 that solves a fundamental problem: how to connect AI to external tools and contexts in a standardized and secure way. With MCP, Claude can be connected to any service: web browser, Google Drive, GitHub, Slack, Notion, databases, external APIs, remote file systems. Instead of AI being an isolated system, it becomes an integrated part of a tool ecosystem. This is the architecture that is defining how AI will operate in professional environments for years to come."},
    {"type":"text","content":"The convergence of Claude Code + MCP + Prompt Engineering is creating a new category of professional: the AI Engineer — someone who doesn't necessarily write all the code manually, but who knows how to orchestrate AI systems to build real products. This professional is extremely rare and extremely valued. Companies of all sizes are racing to find people with this profile. You're learning the foundation of this right now — ahead of most professionals in the market who don't even know what MCP is yet."}
  ]$blocks$::jsonb
WHERE slug = 's4-claude-code-mcp';

-- ============================================================
-- CHALLENGES: question_en + options_en (32 = 2 por licao)
-- ============================================================
-- Identificacao por (slug, pos): pos vem de ROW_NUMBER OVER PARTITION BY
-- lesson_id ORDER BY id, ou seja, pos=1 e' a 1a Q inserida na 005,
-- pos=2 e' a 2a (mesma ordem do PT). UPDATE atomico via JOIN.

WITH ranked AS (
  SELECT c.id, c.lesson_id, l.slug,
         ROW_NUMBER() OVER (PARTITION BY c.lesson_id ORDER BY c.id) AS pos
  FROM challenges c
  JOIN lessons l ON c.lesson_id = l.id
),
translations(slug, pos, question_en, options_en) AS (
  VALUES
    -- s1-o-que-e-ia
    ('s1-o-que-e-ia', 1, 'What is Artificial Intelligence?',
     $opts$["A robot with arms that walks around","A computer that learned by reading billions of texts and conversations","A very hard video game","A camera app"]$opts$::jsonb),
    ('s1-o-que-e-ia', 2, 'Which of these shows AI working in everyday life?',
     $opts$["A light bulb that turns on when you flip a switch","YouTube suggesting cartoons you like to watch","A TV that turns on with a remote control","A pencil that writes by itself"]$opts$::jsonb),
    -- s1-quem-e-claude
    ('s1-quem-e-claude', 1, 'Who created Claude?',
     $opts$["Google","Disney","Anthropic","Nintendo"]$opts$::jsonb),
    ('s1-quem-e-claude', 2, 'What does Claude do when she doesn''t know the answer?',
     $opts$["Makes up any answer","Goes silent forever","Honestly says she doesn''t know","Asks another computer"]$opts$::jsonb),
    -- s1-como-conversar-claude
    ('s1-como-conversar-claude', 1, 'What is a Prompt?',
     $opts$["The name of a cartoon character","Everything you write to Claude","A special button on the keyboard","A robot language"]$opts$::jsonb),
    ('s1-como-conversar-claude', 2, 'Which request will get a better answer from Claude?',
     $opts$["Tell me a story","Story","Tell me an adventure story about Sonic and Tails where they need to save an island full of animals","Do something"]$opts$::jsonb),
    -- s1-claude-conta-historias
    ('s1-claude-conta-historias', 1, 'What information helps Claude create a better story?',
     $opts$["Just the title","Character name, type of story, setting, and the ending you want","Today''s date","How many pages you want"]$opts$::jsonb),
    ('s1-claude-conta-historias', 2, 'What can you do if you didn''t like the story''s ending?',
     $opts$["Nothing, it can''t be changed","Ask Claude for a different ending","Start completely over from scratch","Delete the message and pretend you never read it"]$opts$::jsonb),
    -- s2-o-que-e-api
    ('s2-o-que-e-api', 1, 'What is an API?',
     $opts$["A type of computer virus","A way for two programs to communicate and share data over the internet","A secret game mode in Roblox","A video editing application"]$opts$::jsonb),
    ('s2-o-que-e-api', 2, 'What happens when an app uses an API?',
     $opts$["The app temporarily stops working","The app sends a request and receives data from another server as a response","The app downloads new characters","The app sends a notification to the phone"]$opts$::jsonb),
    -- s2-json-lingua-apis
    ('s2-json-lingua-apis', 1, 'What is JSON?',
     $opts$["A programming language for creating mobile games","An organized format with keys and values that APIs use to send data","An image editing application","A type of gaming server"]$opts$::jsonb),
    ('s2-json-lingua-apis', 2, 'In JSON, how is a list of items represented?',
     $opts$["With asterisks *","Inside square brackets [ ]","Inside parentheses ( )","With loose commas"]$opts$::jsonb),
    -- s2-apis-gratuitas
    ('s2-apis-gratuitas', 1, 'What happens when you access catfact.ninja/fact in your browser?',
     $opts$["It opens an online cat game","The API returns a JSON with a random, curious fact about cats","You need to create an account to see anything","It automatically downloads an app"]$opts$::jsonb),
    ('s2-apis-gratuitas', 2, 'How can you see API data without needing to write any code?',
     $opts$["Installing a special hacker tool","Opening the API URL directly in the browser like a regular website","Downloading the data as a PDF","Asking an adult to do it for you"]$opts$::jsonb),
    -- s2-claude-apis-superpoder
    ('s2-claude-apis-superpoder', 1, 'How does the Claude + API combo work?',
     $opts$["Claude accesses the API on her own without you doing anything","You grab data from the API and ask Claude to transform it into something useful or creative","The API completely replaces Claude","You need to code to use both together"]$opts$::jsonb),
    ('s2-claude-apis-superpoder', 2, 'Which famous app uses a combo similar to API + AI?',
     $opts$["A phone calculator","Spotify, which uses your listening data to create personalized recommendations","An offline game with no internet","The phone''s clock"]$opts$::jsonb),
    -- s3-o-que-e-codigo
    ('s3-o-que-e-codigo', 1, 'Which web language defines HOW things look visually on the screen?',
     $opts$["HTML","Python","CSS","JSON"]$opts$::jsonb),
    ('s3-o-que-e-codigo', 2, 'What happens when you clearly describe what you want to Claude?',
     $opts$["She refuses because it''s too complex","She writes the complete code based on your description","She asks you to learn programming first","She charges for advanced projects"]$opts$::jsonb),
    -- s3-claude-escreve-codigo
    ('s3-claude-escreve-codigo', 1, 'Where can you test HTML code without installing anything?',
     $opts$["In Google Docs","On CodePen.io","In Canva","In Notion"]$opts$::jsonb),
    ('s3-claude-escreve-codigo', 2, 'Why does detailing your code request improve the result?',
     $opts$["Claude works faster with longer requests","It gives Claude precise information to create exactly what you imagined","Longer requests get priority on the server","Claude automatically ignores short requests"]$opts$::jsonb),
    -- s3-receita-site-perfeito
    ('s3-receita-site-perfeito', 1, 'Why does specifying the AUDIENCE in a website request make a difference?',
     $opts$["It makes no difference at all","It allows Claude to adjust the tone, visual style, and features for who will actually use it","The server runs faster with that information","It''s required by platform rules"]$opts$::jsonb),
    ('s3-receita-site-perfeito', 2, 'Why is it important to mention that the website needs to work on mobile?',
     $opts$["It''s not important — every website automatically works on mobile","Because most people access websites from their phones and the layout needs to adapt","Because CodePen only tests the mobile version","Claude only creates mobile versions by default"]$opts$::jsonb),
    -- s3-site-api-app-real
    ('s3-site-api-app-real', 1, 'What separates a static website from an app with an API?',
     $opts$["The app has a better design","The app fetches real-time data from the internet through APIs","The website is free and the app is paid","The app only works on mobile"]$opts$::jsonb),
    ('s3-site-api-app-real', 2, 'Which JavaScript function is used to call an API?',
     $opts$["get()","load()","fetch()","call()"]$opts$::jsonb),
    -- s4-prompt-engineering
    ('s4-prompt-engineering', 1, 'Which pillar of Prompt Engineering defines the role the AI should take?',
     $opts$["Format","Objective","Persona","Examples"]$opts$::jsonb),
    ('s4-prompt-engineering', 2, 'Why does providing EXAMPLES in a prompt improve the AI''s response?',
     $opts$["The AI technically requires examples to function","Examples concretely demonstrate the expected quality standard, allowing the AI to calibrate its response","Examples make the prompt shorter","Anthropic requires examples as part of internal policies"]$opts$::jsonb),
    -- s4-prompts-poderosos-vs-fracos
    ('s4-prompts-poderosos-vs-fracos', 1, 'Why is specifying the TARGET AUDIENCE in a content prompt essential?',
     $opts$["It''s a technical requirement of Anthropic''s API","The audience defines tone, vocabulary, examples, and depth level of the response","It makes no relevant difference in the result","The AI can''t work without that information"]$opts$::jsonb),
    ('s4-prompts-poderosos-vs-fracos', 2, 'What does the "mental test" principle for evaluating prompt quality check for?',
     $opts$["Whether the prompt has more than 100 words","Whether a senior professional would have enough information to deliver the result without guessing anything","Whether all 5 pillars were used in the correct order","Whether the prompt is written in English for better results"]$opts$::jsonb),
    -- s4-system-prompts
    ('s4-system-prompts', 1, 'What differentiates a System Prompt from a regular prompt?',
     $opts$["The System Prompt is sent by the user during the conversation","The System Prompt defines the agent''s base behavior before any interaction, being invisible to the user","The System Prompt is longer than a regular prompt","The System Prompt uses a special programming language"]$opts$::jsonb),
    ('s4-system-prompts', 2, 'Why do companies like Duolingo and Notion invest in Prompt Engineering for System Prompts?',
     $opts$["It''s a legal requirement for using AI APIs","It transforms a generic AI into a product with specific identity, behavior, and utility","It reduces API costs by 50%","It''s required to publish apps on the App Store"]$opts$::jsonb),
    -- s4-claude-code-mcp
    ('s4-claude-code-mcp', 1, 'What can Claude Code do that the web version cannot?',
     $opts$["Respond in more languages","Read and write local files, execute code, and build complete projects on your computer","Generate higher resolution images","Respond with no word limit"]$opts$::jsonb),
    ('s4-claude-code-mcp', 2, 'What is MCP — Model Context Protocol?',
     $opts$["A programming language created by Anthropic","An open standard that allows connecting AI to external tools like GitHub, Notion, and databases in a standardized way","A more advanced AI model than Claude Sonnet","A security protocol for encrypting conversations"]$opts$::jsonb)
)
UPDATE challenges c
SET question_en = t.question_en,
    options_en = t.options_en
FROM ranked r, translations t
WHERE c.id = r.id
  AND r.slug = t.slug
  AND r.pos = t.pos;

COMMIT;

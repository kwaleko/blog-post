# A full backend for a blog site
## Architecture
This code is built and organzied to comply with uncle bob architecturer [for more info](https://8thlight.com/blog/uncle-bob/2012/08/13/the-clean-architecture.html). the main idea in this architecture is the the main logic does not depend on the the web or on the database or any details. in other main the main logic of the application does not import any database or anything.
to follow this architecture, the code is divided into two part
  * Core
  * Adapter

the Core folder contains all the logic and use cases( or bahviour ) of the blog system and does not now anything about the database or the web
the Adapter folder hold the the implemententation of the database and the REST api.
### but why?
following the above structure, I can change a specific database and plug anoher without changing any line of code in the logic of the system

## Functionality
This is a very simple and minimalistic blog site where the follow can be done :
- Any user can register to the blog
- A regsiter User can log into the blog
- A logged in User has access to Create a new article
- A logged in User can update and delete his own articles
- Anyone can views all articles or Articles by Tags or by slug
### REST API
the functionality is provided through REST API using endpoints. Servant is used to serve the API. the API code is availble in the [Adapter/API.hs](https://github.com/kwaleko/blog-post/blob/master/src/Adapter/API.hs)

### Parsing for styling
The blog provide a parsing libray for styling the article, almost close to the to the way it is done on stackoverflow and reddit where
- Text between doubte start is Bold.
- Text between two single star is italic.
- Text betwee two ## is higlighted .
- Text between two [] followed by two parentheses if for URL.
- Text bottomed by equal sign is for heading

the parser does read the above tag and parse and identify the text style. for more information about the parser is implemented check [Core.Parsing.hs](https://github.com/kwaleko/blog-post/blob/master/src/Core/Parsing.hs)

### Database
The Database for this bog is very simple and it is implmeneted using SQLite. two module are responsible for the database. [module for SQL Quereies](https://github.com/kwaleko/blog-post/blob/master/src/Adapter/SQL.hs) and [module as interface for Sqlite](https://github.com/kwaleko/blog-post/blob/master/src/Adapter/Sqlite.hs) and ofcourse both module are implemented in the Adapter folder since these are just details which can be changed and not the main logic of the application

### App Logic
As said before, the main logic of the application is in the [Core folder](https://github.com/kwaleko/blog-post/tree/master/src/Core) which contain the follwoing use-case:
- Mange article use-case
- Manage users use-case
- Parsing artilce use-case
- Monadic interface as classes to be implemented by the DB

## Technicals
 ### Handling errors :
 The monad ExceptT is used to handle error
 ### Database configuration
 The ReaderT monad is used to handle passing the configuration for each DB function
 ### Parsing
 the Attoparsec library is used to implement the parser
 ### REST API
 Servant is used to make REST API
 ### Monadic functions
 all the function are abstracted to use (Monad m) instead of using IO monad or any other specific monad, this case the implemetation could be done used any monad or combination of monad transformer and we don't have to stick to IO.

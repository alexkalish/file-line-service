# File Line Service

## Questions

### How does your system work? (if not addressed in comments in source)

My system is a Ruby on Rails application.  Upon app boot, it pre-processes the file, line by line.  It stores the length of each line in memory in an array indexed to line number.  Secondly, it maintains an open file object for servicing user requests.  When a user request is received, it sums the length of all preceding lines, uses seek to move the file position directly to the requested line and reads it.  It uses the Puma web server to spawm multiple worker processes for responding to current user requests.  After boot, each worker reopens the file to ensure that it has a new entry in the OS file table to avoid any file position race conditions and to ensure concurrent reads.

### How will your system perform with a 1 GB file? a 10 GB file? a 100 GB file?

I've tested it locally with a variety of file sizes and here are some anedotal but repeatable averaged results.  Each file had 500 character length lines.

| File Size | Total Lines | Request Line 1 (ms) | Request Line n (ms) |
| ---: | ---: | ---: | ---: |
| 1MB | 2.5k | 5 | 5 |
| 10MB | 25k | 5 | 5 |
| 100MB | 250k | 5 | 25 |
| 1GB | 2.5M | 5 | 200 |
| 10GB | 25M | 5 | 2k|

When requesting line 1, I would see 25ms every 5 request, which I can't totally explain.  Also, memory usage increased dramatically with larger files, which completely makes sense.  Each worker process stores it's own copy of the file metadata in memory.  For a 1GB file, workers used about 52MB, while a 10GB file resulted in 150-200GB workers.

Clearly, this solution as built doesn't handle multi-gigabyte files well, but I think this can be pretty easily helped. I have a few ideas:

* Since the code is always seeking the line position from the start of the file, it completely makes sense that reading line 1 would be quick and line n would get progressively much worse.  Instead, seek to the difference between the current position and the desired one.  This would likely slow down requests close to line 1, but on average, would probably increase response times.
* Smarter caching could help quite a bit.  I would instrument the controller to track requests by line and timestamp in order to look for file access patterns.  For example, if users typically start at line 1 and progress line by line sequentially through the file, a background process could be added to read and cache lines ahead of current requests.
* When the file is preprocessed, it could be broken up into multiple smaller files, each of which could be 10% of the total size.  Each worker would maintain a file object for each file.
* I don't like this quite as much, but each worker could maintain n open file objects for the file and constrain each one to defined percentage of the file (e.g. 31% - 40%).


### How will your system perform with 100 users? 10000 users? 1000000 users?

I didn't have time to test concurrency performance, though I think it would handle many users pretty easily.  As it stands, the app definitely scales horizontally across multiple servers behind a load balancer.  There would be no shared resource across servers.  Workers share access to the file system for accessing the hosted file, so it's definitely disk IO bound.  If the metadata was moved into a shared cache, it could be hosted per server (i.e. a local on-host Redis instance) in order to not hinder horizontal scaling.  A file line cache would obviously need to be a shared resource across hosts to be most beneficial.  With all of that said, I think scaling from hundreds of users to thousands of users would be pretty doable.  I'm not sure about 1M.

### What documentation, websites, papers, etc did you consult in doing this assignment?

* Official Ruby docs
* Official Rails docs
* Official Puma docs and the Heroku Puma guides
* Wikipedia pages on file systems, file descriptors, etc to refresh my memory

### What third-party libraries or other tools does the system use? How did you choose each library or framework you used?

Rails is the framework that I know best, so it was an easy choice.  I went with 4, since I haven't used 5 yet.  I also used the Puma webserver, which I had not used before.  We us Passenger at work in production, but Puma is now the default for Rails 5 and the configuration looked more straightforward.  As I'll discuss below, if I had more time, I would have used Redis for caching, as it's something that I've used before.  I might have also used Redis or Postgres for the file metadata.

### How long did you spend on this exercise? If you had unlimited more time to spend on this, how would you spend it and how would you prioritize each item?

I probably spent close to a full workday on this, between coding, some iterations, testing and this write up.  I think there is a lot that this system could use if I had more time.  Here is a priority sorted list.  In my mind, the first three items are necessary to hit MVP status for production.  I want to ensure the app works as intended (i.e add tests), fix my biggest gripe with my code (described in the next question) and add basic caching.  After, the order of the other items would depend upon where and how performance would need to be improved.

1. Add unit and integration tests, probably using Rspec. I always write tests for production code.
1. Move hosted file metadata out of worker process memory and into into some shared store, maybe Redis, since I feel like the data could still stay in memory.  Along with this change, I would create a background process script for preprocessing the file so that it wouldn't be done on app boot.  Instead, when the app boots, if the metadata cannot be found, the API would return a 503 until found.
1. Add basic file line caching using the Rails cache API.  Put another way, cache each line by index so that repeated requests do not hit the file system.  I have the API call inthe controller, but no backend configured as I didn't want to bother adding memcached or redis to install.sh.  In addition, I would have the preprocess script warm the cache by inserting each line from the beginning of the file until the cache is full.  For small files, it could probably cache the whole thing.
1. I would try to improve file offset calculations and file seek time.  It might be more effecient to store the complete offset for each line instead of the length to avoid summing all lengths to get a particular offset.  Also, as I mentioend before, it would likely be more effecient to seek to the difference between the current file position and the desired offset.
1. As I mentioned above, I would instrument requests to look for file line access patterns and use that information to improve caching.  For example, if all/most users read line by line from line index 1, a background process could cache the next n lines ahead of each user.  Of course, this may not scale terribly well for tons of concurrent users.
1. Make the app thread-safe to improve concurrency within a single worker.  I think that file access is only thread unsafe part.  Instead of having a single file object per worker, I would need one per thread.  This would probably be best accomplished with a pool of file objects.

### If you were to critique your code, what would you have to say about it?

My solution ended up being less code than I would have thought when I first concieved it, which I'm happy about.  Looking at all the limitations and future ideas that I've described in this document, it's definitely a prototype.  The more I think about it, the more I find places that can be improved, which I'm mostly described in the questions above.  The part of the final design that I like the least is storing metadata in memory and preprocessing the file on app boot.  They were both shortcuts to get this working that I would definitely want to correct.

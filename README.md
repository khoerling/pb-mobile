# Skeleton

## MySQL Setup

    Generate a site.sql
    mysql -uroot
    CREATE DATABASE Site;
    GRANT ALL PRIVILEGES ON Site.* TO 'root'@'localhost' IDENTIFIED BY 'vagrant';
    FLUSH PRIVILEGES;
    use Site;
    \. db/Site.sql
    quit;

    cd db
    ./knex migrate:latest

    cd ..
    mysql -uroot -pvagrant Site


## Environment Variables

* `PORT`        -- port to listen on
* `DB_DEBUG`    -- if true, enable Bookshelf's debugging output
* `DB_HOST`     -- hostname of MySQL server
* `DB_USER`     -- MySQL user
* `DB_PASSWORD` -- MySQL password
* `DB_NAME`     -- MySQL database name

## OSX Firewall Setup (for using Vagrant on a host)

    ipfw add fwd 127.0.0.1,3001 tcp from any to me dst-port 80

## References

* **Express.js** -- http://expressjs.com/api.html
* **Bookshelf.js** -- http://bookshelfjs.org/
    * **Knex.js** -- http://knexjs.org/
    * **Backbone.js**
        * **Backbone.Model** -- http://backbonejs.org/#Model
        * **Backbone.Collection** -- http://backbonejs.org/#Collection
        * **Underscore.js** -- http://underscorejs.org/
* **LiveScript** -- http://livescript.net/
    * **Prelude.ls** -- http://preludels.com/
* **React** -- http://facebook.github.io/react/docs/getting-started.html

## Test Data

* ./bin/repl


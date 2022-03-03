# `migrator`

`migrator` allows you to write your postgres schema directly in *declarative sql*, and to automatically generate migrations when you change that declarative schema.

**No more orms!** Use the full power of postgres directly without having to manually write migrations.

Turns out generating and running migrations isn't that hard! Especially if:

- You don't bother making migrations reversible, and instead just make a new migration if you want to undo something (that's best practice anyway).
- You don't worry about only running migrations up to a certain version.
- Schema diffing is taken care of by someone else! Thank you [`migra`](https://github.com/djrobstep/migra)!

# Usage

First, place your declarative sql files in the `schema` directory and create a directory for migrations called `migrations`. You can customize these with `--schema-directory` and `--migrations-directory`.

`migrator` is a cli that is distributed as a docker image, `blainehansen/migrator`. You can run it using `docker run`, and since the cli needs to interact with a postgres database, read schema files, and read/write migration files, it needs quite a few options:


```bash
docker run --rm -it --network host -u $(id -u ${USER}):$(id -g ${USER}) -v $(pwd):/working blainehansen/migrator <args>
```

To make this easier to manage, you can package that command in a function or alias:

```bash
function migrator {
  local result=$(docker run --rm -it --network host -u $(id -u ${USER}):$(id -g ${USER}) -v $(pwd):/working blainehansen/migrator "$@")
  echo $result
}

# or
alias migrator="docker run --rm -it --network host -u $(id -u ${USER}):$(id -g ${USER}) -v $(pwd):/working blainehansen/migrator"


# now you can call it more cleanly
migrator --dbname "experiment_db" --user "experiment_user" migrate 'adding users table'
migrator --dbname "experiment_db" --user "experiment_user" up
```

Here's the cli usage:

```
USAGE:
    migrator [OPTIONS] <SUBCOMMAND>

OPTIONS:
        --dbname <DBNAME>
        --host <HOST>                                    [default: localhost]
        --password <PASSWORD>
        --port <PORT>                                    [default: 5432]
        --user <USER>
        --migrations-directory <MIGRATIONS_DIRECTORY>    [default: migrations]
        --schema-directory <SCHEMA_DIRECTORY>            [default: schema]
    -h, --help                                           Print help information
    -V, --version                                        Print version information

SUBCOMMANDS:
    help       Print this message or the help of the given subcommand(s)
    migrate    generate new migration and place in migrations folder
    up         apply all migrations to database
    diff       prints out the sql diff necessary to convert `source` to `target`
    compact    ensure both database and migrations folder are current with schema, and compact
               to only one migration
    clean      cleans the current instance of all temporary databases
```

<!-- The script can:

- Generate migrations in the format `$date_timestamp.$description.sql` into a `migrations` directory, using the `migrate <description>` subcommand.
- Run all unperformed migrations and insert the version number of each into a `_schema_versions` table, using the `up` subcommand.
- Compact all migrations into a single migration, using the `compact` subcommand. -->

## What is `compact`?

Over time a migrations folder can get large and unwieldy, with possibly hundreds of migrations. This long log gets less and less useful over time, especially for small teams. The `compact` command replaces all migrations with a single migration that creates the entire schema at once.

Some teams will consider this dangerous and unnecessary, and they're free to not use it!

# Example

If your `schema` directory contains a sql file like this:

```sql
create table fruit (
  id serial primary key,
  name text not null unique,
  color text not null default ''
);
```

Then running `migrator migrate 'add fruit table'` will generate a migration called `$date_timestamp.add_fruit_table.sql` in the `migrations` folder.

If you then change your schema sql to this:

```sql
create type flavor_type as enum('SWEET', 'SAVORY');

create table fruit (
  id serial primary key,
  name text not null unique,
  flavor flavor_type not null default 'SWEET'
);
```

Then running `migrator migrate 'remove color add flavor'` will generate `$date_timestamp.remove_color_add_flavor.sql` that will go from the previous state to the new state.

# Contributing

Pull requests making the script more ergonomic or robust are welcome.

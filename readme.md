# DB isolation levels

* Isolation levels
  * [Read committed](#read-committed-isolation-level)
  * [Snapshot (repeatable read)](#snapshot-repeatable-read-isolation-level)
  * [Read uncommitted](#read-uncommitted)
* [Lost update](#lost-update)
* [Atomic updates](#atomic-updates)
* [Mysql notes](#mysql-notes)




## Read committed isolation level

### Explanation
```

transaction 1            commited
=========================>
                         |transaction 2 can already read changes made by transaction 1
transaction 2            |
======================================================>

```

Transaction 2 can read changes, that have been committed by transaction 1

### Example

```mysql

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION ;

SELECT COUNT(*) FROM emails WHERE user_id = 1;

#   INSERT ... INTO emails;  // Another transaction

SELECT * FROM emails WHERE user_id = 1;

COMMIT;

```

In example above emails count `SELECT COUNT(*) FROM emails` will be one email less than
count of rows in `SELECT * FROM emails`

It happens because another transaction have been committed between these operations
and added one email

To avoid this error use next isolation level








## Snapshot (repeatable read) isolation level

### Explanation
```

transaction 1            commited
=========================>
                          transaction 2 can't read changes made by transaction 1
transaction 2             
======================================================>
|
|
transaction 2 made a snapshot of database and don't see any changes

```

### Example

```mysql

SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

START TRANSACTION ;

SELECT COUNT(*) FROM emails WHERE user_id = 1;

#   INSERT ... INTO emails;  // Another transaction

SELECT * FROM emails WHERE user_id = 1;

COMMIT;

```

In example above `SELECT COUNT(*) FROM emails` and `SELECT * FROM emails` will return the same amount of rows

This transaction can't see another transaction's changes



## Read uncommitted

### Explanation

```
                   one of many operations in transaction 1
                   |
transaction 1      |      rollback
===================|======X
                   |transaction 2 can read changes made by transaction 1
transaction 2      |       
===================|==================================>
                   |
                   |
                   transaction 2 can read uncommitted changes made by transaction 1
                   also called as "Dirty read"
```

I can't imagine situation when read uncommitted isolation level needed.

Should be avoided in most cases.



## Lost update

```mysql

# transaction 1
START TRANSACTION;

SELECT value FROM counter INTO @value; # @value = 1

UPDATE counter SET value = @value + 1 WHERE id = 1; # set value to 2

COMMIT;


# transaction 2
START TRANSACTION;

SELECT value FROM counter INTO @value; # @value = 1

#=========================================================
# transaction 1 running
#=========================================================

UPDATE counter SET value = @value + 1 WHERE id = 1; # set value to 2 again

COMMIT;

```

In example above both transactions will read `value = 1` and set `value` to `2`.

Updating `value` by transaction 2 will be lost

It may happen with any transaction isolation levels.

To prevent this error [Atomic updates](#atomic-updates) should be used.




## Atomic updates

```mysql

# transaction 1
START TRANSACTION;

UPDATE counter SET value = value + 1 WHERE id = 1;

COMMIT;


# transaction 2
START TRANSACTION;

# waiting for unlocking
UPDATE counter SET value = value + 1 WHERE id = 1;

COMMIT 

```

In example above value will be updated 2 times and no operations will be lost



## Mysql notes

Default mysql isolation level is [Snapshot (repeatable read)](#snapshot-repeatable-read-isolation-level)

To set isolation level for session
```mysql
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

To set isolation level globally
```mysql
SET GLOBAL TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```
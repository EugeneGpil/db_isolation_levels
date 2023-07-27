# DB isolation levels

* [Isolation levels](#isolation-levels)
  * [Read committed](#read-committed-isolation-level)
  * [Snapshot (repeatable read)](#snapshot-repeatable-read-isolation-level)
  * [Read uncommitted](#read-uncommitted)
* [Lost update](#lost-update)
  * [Lost update](#lost-update-1)
  * [Atomic updates](#atomic-updates)
  * [Explicit lock](#explicit-lock)
  * [Lost update detection](#lost-update-detection)
* [Shared and exclusive locks](#shared-and-exclusive-locks)
  * [Shared lock](#shared-lock)
  * [Exclusive lock](#exclusive-lock)
* [Mysql notes](#mysql-notes)



## Isolation levels

### Read committed isolation level

```

transaction 1            commited
=========================>
                         |transaction 2 can already read changes made by transaction 1
transaction 2            |
======================================================>

```

Transaction 2 can read changes, that have been committed by transaction 1

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








### Snapshot (repeatable read) isolation level

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



### Read uncommitted

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

### Lost update

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




### Atomic updates

```mysql

# transaction 1
START TRANSACTION;

# set exclusive lock
UPDATE counter SET value = value + 1 WHERE id = 1;

COMMIT;
# release exclusive lock


# transaction 2
START TRANSACTION;

# waiting for unlocking
UPDATE counter SET value = value + 1 WHERE id = 1;

COMMIT 

```

In example above value will be updated 2 times and no operations will be lost.

In this example in case of using [repeatable-read](#snapshot-repeatable-read-isolation-level) isolation level
changes made by transaction 1 will be read by transaction 2 anyway.

In this example [exclusive lock](#exclusive-lock) is used to prevent operations lost.



### Explicit lock

```mysql

# transaction 1
START TRANSACTION;

# set exclusive lock
SELECT value FROM counter WHERE id = 1 INTO @value FOR UPDATE;

UPDATE counter SET value = @value + 1 WHERE id = 1;

COMMIT;
# release exclusive lock


# transaction 2
START TRANSACTION;

# waiting for unlocking
SELECT value FROM counter WHERE id = 1 INTO @value FOR UPDATE;

UPDATE counter SET value = @value + 1 WHERE id = 1;

COMMIT;

```

It's just like [atomic update](#atomic-updates), but more manually.



#### Lost update detection

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

COMMIT; -- <== ROLLBACK; # Rolled back by transaction manager

```

For lost update detection need to use transaction manager.
Transaction manager determines that current transaction will lead to lost update and rolling back this transaction.



### Shared and exclusive locks

#### Shared lock

Shared locks allow multiple transactions to read the same data simultaneously,
but prevents modification until all shared locks have been released.

Shared locks are also called `read locks`, and are used for maintaining read integrity.

```mysql
-- TODO:Example
```

#### Exclusive lock

Exclusive locks allow only one transaction access to read or modify data at a given time.
No other transaction can read or modify the data until the current transaction releases its exclusive lock.
Exclusive locks are also known as `write locks`.

```mysql

START TRANSACTION;

SELECT count FROM store WHERE product = 'apple' INTO @value FOR UPDATE;

UPDATE store SET count = @value - 10 WHERE product = 'apple';

COMMIT;

```



### Mysql notes

Default mysql isolation level is [Snapshot (repeatable read)](#snapshot-repeatable-read-isolation-level)

To set isolation level for session
```mysql
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

To set isolation level globally
```mysql
SET GLOBAL TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```
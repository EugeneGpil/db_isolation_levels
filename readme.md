# DB isolation levels

* [Read committed](#read-committed-isolation-level)
* [Snapshot (repeatable read)](#snapshot-repeatable-read-isolation-level)





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

START TRANSACTION ;

SELECT COUNT(*) FROM emails WHERE user_id = 1;

#   INSERT ... INTO emails;  // Another transaction

SELECT * FROM emails WHERE user_id = 1;

COMMIT;

```

In example above `SELECT COUNT(*) FROM emails` and `SELECT * FROM emails` will return the same amount of rows

This transaction can't see another transaction's changes

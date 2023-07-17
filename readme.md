# DB isolation levels

## Read committed

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

#   INSERT ... INTO emails;  //Another transaction

SELECT * FROM emails WHERE user_id = 1;

COMMIT

```

In example above emails count `SELECT COUNT(*) FROM emails` will be one email less then
count of rows in `SELECT * FROM emails`

It happens because another transaction have been committed between this operations
and added one email

To avoid this error need to use `Snapshot isolation` or `Repeatable read`

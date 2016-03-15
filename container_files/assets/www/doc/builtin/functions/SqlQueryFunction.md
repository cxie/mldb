# SQL Query Function

The SQL query function type allows the creation of a function to perform an
[SQL query](../sql/Sql.md) against a dataset.
The query is parameterized on the function input values.
SQL query function allows for joins to be implemented
in MLDB.

Functions created this way executes the given query against the given dataset,
and return a single row (the details of row construction is given below).

## Configuration

![](%%config function sql.query)

The `output` field has the following possible values:

![](%%type Datacratic::MLDB::SqlQueryOutput)


## Accessing function input values

The function input values are declared in the SQL query by
prefixing their name with a `$` character.  For UTF-8 names
or those that are not simple identifiers, it is necessary to
put them inside '"' characters.  For example,

- `$x` refers to the input value named `x`.
- `$"x and y"` refers to the input value named `x and y`.

The input values are available in the entire expression, including
as part of table expressions or join expressions.

## Output format

There are two possibilities for the output:

1.  If the `output` field is set to `FIRST_ROW` (the default), then
    it will outputs the `SELECT` expression applied to the first matching
    row (ie, with an `OFFSET` of 0 and a `LIMIT` of 1).  If multiple
    rows are matched, all but the first will be ignored.
2.  If the `output` field is set to `NAMED_COLUMNS`, then the query
    must return a two-column dataset with a `column` and a `value`
    each column.  Each row  in the output will generate a single
    column in the output row, with the column name equal to value of the
    `column` column, and the column value equal to the value of the
    `value` column.  In this case the `OFFSET` and `LIMIT` will be
    respected.  This allows for more sophisticated rows to be returned
    from queries, and is especially useful in conjunction with joins.

As an example, if the table returned from the query is the following

```
column value
x      1
y      2
```

then for a `FIRST_ROW` output, we will produce the row corresponding
to the first row of the table, viz

```
column value
x      1
```

whereas for a `NAMED_COLUMNS` output, we will produce the row with one
column per output row:

```
x y
1 2
```

Note that the `FIRST_ROW` could accept any output format from the query,
whereas the output for `NAMED_COLUMNS` must have exactly the two columns
given.

## Restrictions

- It is normally best to use a query with a tight `WHERE` clause
  so that it is not necessary to scan the whole table.  Otherwise
  the queries may be very slow.
  

## Example

The following function configuration add information about a user
looked up from a `users` table.  The user to be queried is read from
the `userId` input value.  A second `details` input value controls
whether or not and extra field is calculated.

The function outputs three values:

- the `age` of the user that is read directly from the `age` column of the `users`
  dataset;
- the `gender` which is also read directly from the `gender` column of the
  `users` dataset;
- the `activationYears` which is equal to 1/365 of the
  `activationDays` column of the `users` dataset if the `details`
  value is true, or `null` otherwise.

```
{
    id: "query",
    type: "sql.query",
    params: {
        select: "age, gender, CASE WHEN $details THEN activationDays / 365.0 ELSE NULL AS activationYears",
        from: { id: 'users' },
        where: 'rowName() = $userId',
        output: 'FIRST_ROW'
    }
}
```

## See also

* [MLDB's SQL Implementation](../sql/Sql.md)
* the ![](%%doclink sql.expression function) calculates pure SQL
  expressions, without a dataset involved.
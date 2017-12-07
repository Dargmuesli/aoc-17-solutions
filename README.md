# Advent of Code 2017 Solutions

## Description
These are my solutions for [AoC 2017](http://adventofcode.com/).
They are encrypted using the each challenges' solution as password.

Use the decrypt script to make the content readable.
Execute the following command after populating the .env file.

```PowerShell
.\Crypt.ps1 -Task "Decrypt" -All
```

You can also encrypt and choose single files to perform the operation on:

```PowerShell
.\Crypt.ps1 -Task "Encrypt" -Door 1 -Part "A" -Solution 123
```

# PsWhich

Provide equivalent of Unix 'which' and 'where' command in PowerSell.

## Installation

    cd $env:USERPROFILE\Documents\WindowsPowerShell\Modules
    git clone git://github.com/erw7/PsWhich.git PsWhich

## Configuration

Add the following to your $PROFILE.

    Import-Module PsWhich

## Basic usage

#### Get-CommandPath -Path <String>

Show the full path of commands.

#### Get-CommandPath -All -Path <String>

Show the all full path of commands.

function Get-CommandPath
{
    Param (
        [switch]$All,
        [parameter(Mandatory=$true)]
        [string]$Path
    )

    $pattern = "^(\\|\.\.?|[a-z]:\\)"

    if ($Path -match $pattern)
    {
        $pattern = "\\[^\\]+\.(" + [string]::Join("|", $env:PATHEXT.replace(".","").split(";")) + "|PS1)$"

        if (-not ($Path -match $pattern))
        {
            Not-Found($Path)
            return
        }
    }

    try {
        $cmd = Get-Command $Path -ErrorAction Stop
    }
    catch [Exception]
    {
        Not-Found($Path)
        return
    }

    switch ($cmd.CommandType)
    {
        "Alias"
        {
            Write-Output($Path + ": aliased to " + $cmd.Definition)
            break
        }
        "Cmdlet"
        {
            Write-Output($Path + ": Cmdlet")
            break
        }
        {"Filter", "Function", "Workflow" -contains $_}
        {
            Write-Output $cmd.Definition
            break
        }
        default #Application, ExternalScript, Script
        {
            if (-not $All)
            {
                Write-Output $cmd.Definition
            }
            break
        }
    }

    if ($All)
    {
        Search-Path($Path)
    }
}

function Search-Path
{
    Param(
        [parameter(Mandatory=$true)]
        [string]$Target)

    $pattern = "[^\\]+\.(" + [string]::Join("|", $env:PATHEXT.replace(".","").split(";")) + "|PS1)$"
    if (-not ($Target -match $pattern))
    {
        $Include = ("*" + $env:PATHEXT.replace(";",";*")).split(";")
        $Include += "*.PS1"
        $Target += ".*"
    }

    $env:PATH.split(";").ForEach(
        {
            $BasePath = $_
            $SearchPath = Join-Path $BasePath $Target
            try {
                $ChildItem = Get-ChildItem $SearchPath -Include $Include -ErrorAction Stop
                if (-not ($null -eq $ChildItem))
                {
                    If ($ChildItem -is [array])
                    {
                        $ChildItem.ForEach({Write-Output(Join-Path $BasePath $_)})
                    }
                    else
                    {
                        Write-Output(Join-Path $BasePath $ChildItem.Name)
                    }
                }
            }
            catch [Exception]
            {
                return
            }
        }
    )
}

function Get-AllCommandPath
{
    Param (
        [parameter(Mandatory=$true)]
        [string]$Path
    )
    Get-CommandPath -All $Path
}

function Not-Found($Path)
{
        Write-Output($Path + " not found")
}

Set-Alias which Get-CommandPath
Set-Alias wherecmd Get-AllCommandPath

Export-ModuleMember -Function Get-CommandPath, Get-AllCommandPath -Alias "Which", "wherecmd"

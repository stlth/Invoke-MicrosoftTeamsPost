<#PSScriptInfo
.VERSION 1.0.1
.GUID 1f34da03-9758-4561-8d20-755ca4d6dc2c
.AUTHOR Cory Calahan
.COMPANYNAME
.COPYRIGHT (C) Cory Calahan. All rights reserved.
.TAGS Microsoft Teams,Teams,Card,Post
.LICENSEURI
.PROJECTURI
    https://github.com/stlth/Invoke-MicrosoftTeamsPost
.ICONURI
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
.Synopsis
   Post a card to Microsoft Teams
.DESCRIPTION
   Build a message and posts as a card to a Microsoft Teams Channel
.EXAMPLE
   PS> $wh = 'https://outlook.office365.com/webhook/a1269812-6d10-44b1-abc5-b84f93580ba0@9e7b80c7-d1eb-4b52-8582-76f921e416d9/IncomingWebhook/3fdd6767bae44ac58e5995547d66a4e4/f332c8d9-3397-4ac5-957b-b8e3fc465a8c'
   PS> $red = 'FF0000'
   PS> Invoke-MicrosoftTeamsPost -WebhookURL $wh -Title 'Alert!' -MarkdownBody 'Something has broken on [Server](http://localhost/)!' -ThemeColor $red
.NOTES
   Version:        1.0.1
   Author:         Cory Calahan
   Date:           2017-03-24
   Purpose/Change: Initial function development
#>
<#
.PARAMETER WebhookURL
   Webhook of Microsoft Team Channel to post against   
.PARAMETER Title
    An optional title to add to a posting
.PARAMETER Body
    Content (in Markdown or basic text) of the posting
.PARAMETER ThemeColor
    An optional HEX color code (e.g. 'EA4300') to apply to the posting
#>
function Invoke-MicrosoftTeamsPost
{
#Requires -Version 3.0
    [CmdletBinding(DefaultParameterSetName='Default', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  ConfirmImpact='Medium')]
    Param
    (
        # Webhook of Microsoft Team Channel to post against
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='Default')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Webhook')] 
        [string]
        $WebhookURL,
        # An optional title to add to a posting
        [Parameter(Mandatory=$false,
                   Position=1,
                   ParameterSetName='Default')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Title,
        # Content (in Markdown or plain text) of the posting
        [Parameter(Mandatory=$true,
                   Position=2,
                   ParameterSetName='Default')]
        [string]
        [Alias('Markdown')]
        $Body,
        # An optional HEX color code (e.g. 'EA4300') to apply to the posting
        [Parameter(Mandatory=$false,
                   Position=3,
                   ParameterSetName='Default')]
        [ValidatePattern('^([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$')]
        [string]
        [Alias('Color')]
        $ThemeColor
    )

    Begin
    {
        Write-Verbose -Message 'Listing Parameters utilized:'
        $PSBoundParameters.GetEnumerator() | ForEach-Object -Process { Write-Verbose -Message "$($PSItem)" }

        $data = @{'Content-Type'='application/json'}
        if ($Title) {$data.Add('title',$Title)}
        if ($ThemeColor) { $data.Add('themeColor',$ThemeColor) }
        $data.Add('text',$Body)
        Write-Verbose -Message "Data to sent: $($data | Out-String)"
    }
    Process
    {
        if ($PSCmdlet.ShouldProcess("$WebhookURL",'Posting to Microsoft Teams'))
        {
            try
            {
                Invoke-RestMethod -Method 'Post' -Uri "$WebhookURL" -Body (ConvertTo-Json -InputObject $data -Compress:$true) -ErrorAction 'Stop'
            }
            catch
            {
                throw $PSItem
            }
        }
    }
    End
    {
        Remove-Variable -Name data
    }
}

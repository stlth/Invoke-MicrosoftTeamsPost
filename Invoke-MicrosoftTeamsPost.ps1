<#PSScriptInfo
.VERSION 1.0.2
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
   PS> Invoke-MicrosoftTeamsPost -WebhookUri $wh -Title 'Alert!' -Body 'Something has broken on **server**!' -ThemeColor $red -ButtonTitle 'Go to dashboard' -ButtonUri 'http://dashboard/'
.NOTES
   Version:        1.0.2
   Author:         Cory Calahan
   Date:           2017-03-27
   Purpose/Change: Added buttons (PotentialAction)
   Version:        1.0.1
   Author:         Cory Calahan
   Date:           2017-03-24
   Purpose/Change: Initial function development
#>
<#
.PARAMETER WebhookUri
   Webhook of Microsoft Team Channel to post against   
.PARAMETER Title
    An optional title to add to a posting
.PARAMETER Body
    Content (in Markdown or basic text) of the posting
.PARAMETER ThemeColor
    An optional HEX color code (e.g. 'EA4300') to apply to the posting
.PARAMETER ButtonTitle
    Text to display on button
.PARAMETER ButtonUri
    Link to navigate to when button is clicked from Microsoft Teams post
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
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='PotentialAction')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias('Webhook','WebhookUrl')] 
        [string]
        $WebhookUri,
        # An optional title to add to a posting
        [Parameter(Mandatory=$false,
                   Position=1,
                   ParameterSetName='Default')]
        [Parameter(Mandatory=$false,
                   Position=1,
                   ParameterSetName='PotentialAction')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Title,
        # Content (in Markdown or plain text) of the posting
        [Parameter(Mandatory=$true,
                   Position=2,
                   ParameterSetName='Default')]
        [Parameter(Mandatory=$true,
                   Position=2,
                   ParameterSetName='PotentialAction')]
        [string]
        [Alias('Markdown')]
        $Body,
        # An optional HEX color code (e.g. 'EA4300') to apply to the posting
        [Parameter(Mandatory=$false,
                   Position=3,
                   ParameterSetName='Default')]
        [Parameter(Mandatory=$false,
                   Position=3,
                   ParameterSetName='PotentialAction')]
        [ValidatePattern('^([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$')]
        [string]
        [Alias('Color')]
        $ThemeColor,
        [Parameter(Mandatory=$true,
                   Position=4,
                   ParameterSetName='PotentialAction')]
        [string]
        $ButtonTitle,
        [Parameter(Mandatory=$true,
                   Position=5,
                   ParameterSetName='PotentialAction')]
        [string]
        $ButtonUri
    )

    Begin
    {
        Write-Verbose -Message 'Listing Parameters utilized:'
        $PSBoundParameters.GetEnumerator() | ForEach-Object -Process { Write-Verbose -Message "$($PSItem)" }

        $data = @{'Content-Type'='application/json'}
        if ($Title) {$data.Add('title',$Title)}
        if ($ThemeColor) { $data.Add('themeColor',$ThemeColor) }
        $data.Add('text',$Body)
        if ($ButtonTitle)
        {
            $data.Add('potentialAction',@(@{
                                '@context'='http://schema.org'
                                '@type'='ViewAction'
                                'name'="$ButtonTitle"
                                'target'=@("$ButtonUri")
                              }
                            )
                     )
        }
        Write-Verbose -Message "Data to sent: $($data | Out-String)"
    }
    Process
    {
        if ($PSCmdlet.ShouldProcess("$WebhookUri",'Posting to Microsoft Teams'))
        {
            try
            {
                Invoke-RestMethod -Method 'Post' -Uri "$WebhookUri" -Body (ConvertTo-Json -InputObject $data -Compress:$true -Depth 10) -ErrorAction 'Stop'
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

<%@ Register TagPrefix="portal" TagName="Banner" Src="~/DesktopPortalBanner.ascx" %>
<%@ OutputCache Duration="36000" VaryByParam="none" %>
<html>
    <head>
        <title>ASP.NET Portal</title>
        <link rel="stylesheet" href='<%= Request.ApplicationPath + "/Portal.css" %>' type="text/css" />
    </head>
    <body leftmargin="0" bottommargin="0" rightmargin="0" topmargin="0" marginheight="0" marginwidth="0">
        <form runat="server">
            <table width="100%" cellspacing="0" cellpadding="0" border="0">
                <tr valign="top">
                    <td colspan="2">
                        <portal:Banner runat="server" />
                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        <center>
                            <br>
                            <table width="500" border="0">
                                <tr>
                                    <td class="Normal">
                                        <br>
                                        <br>
                                        <br>
                                        <br>
                                        <span class="Head">Edit Access Denied</span>
                                        <br>
                                        <br>
                                        <hr noshade size="1pt">
                                        <br>
                                        Either you are not currently logged in, or you do not have access to modify the 
                                        current portal module content. Please contact the portal administrator to 
                                        obtain edit access for this module.
                                        <br>
                                        <br>
                                        <a href="<%=Request.ApplicationPath%>/DesktopDefault.aspx">Return to Portal Home</a>
                                    </td>
                                </tr>
                            </table>
                        </center>
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>

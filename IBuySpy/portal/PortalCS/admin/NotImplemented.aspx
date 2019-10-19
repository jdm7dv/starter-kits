<%@ Register TagPrefix="portal" TagName="Banner" Src="~/DesktopPortalBanner.ascx" %>
<%@ OutputCache Duration="600" VaryByParam="title" %>
<%--

   This page is the target for the fictious links in the sample data.

--%>
<html>
    <script language="C#" runat="server">

    //****************************************************************
    //
    // The Page_Load event on this Page is used to obtain the title
    // of the fictious content item.
    //
    //****************************************************************

    void Page_Load(Object Sender, EventArgs e) {

        if (Request.Params["title"] != null) {
            title.InnerHtml = Request.Params["title"].ToString();
        }
    }

    </script>
    <head>
        <title>IBuySpy Portal: Content Not Implemented</title>
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
                                        <span id="title" class="Head" runat="server">Linked Content Not Provided</span>
                                        <br>
                                        <br>
                                        <hr noshade size="1pt">
                                        <br>
                                        The link you clicked was provided as a part of the sample data for the <b>IBuySpy</b>
                                        company portal. The content for this link is not provided as part of the sample 
                                        application.
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

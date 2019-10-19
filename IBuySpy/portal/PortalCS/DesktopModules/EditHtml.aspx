<%@ Page Language="C#" %>
<%@ Register TagPrefix="portal" TagName="Banner" Src="~/DesktopPortalBanner.ascx" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="ASPNetPortal" %>
<script runat="server">

    int moduleId = 0;

    //****************************************************************
    //
    // The Page_Load event on this Page is used to obtain the ModuleId
    // of the xml module to edit.
    //
    // It then uses the ASPNetPortal.HtmlTextDB() data component
    // to populate the page's edit controls with the text details.
    //
    //****************************************************************

    void Page_Load(Object Sender, EventArgs e) {

        // Determine ModuleId of Announcements Portal Module
        moduleId = Int32.Parse(Request.Params["Mid"]);

        // Verify that the current user has access to edit this module
        if (PortalSecurity.HasEditPermissions(moduleId) == false) {
            Response.Redirect("~/Admin/EditAccessDenied.aspx");
        }

        if (Page.IsPostBack == false) {

            // Obtain a single row of text information
            ASPNetPortal.HtmlTextDB text = new ASPNetPortal.HtmlTextDB();
            SqlDataReader dr = text.GetHtmlText(moduleId);
            
            if (dr.Read()) {

                DesktopText.Text = Server.HtmlDecode((String) dr["DesktopHtml"]);
                MobileSummary.Text = Server.HtmlDecode((String) dr["MobileSummary"]);
                MobileDetails.Text = Server.HtmlDecode((String) dr["MobileDetails"]);
            }
            else {
            
                DesktopText.Text = "Todo: Add Content...";
                MobileSummary.Text = "Todo: Add Content...";
                MobileDetails.Text = "Todo: Add Content...";
            }
            
            dr.Close();

            // Store URL Referrer to return to portal
            ViewState["UrlReferrer"] = Request.UrlReferrer.ToString();
        }
    }

    //****************************************************************
    //
    // The UpdateBtn_Click event handler on this Page is used to save
    // the text changes to the database.
    //
    //****************************************************************

    void UpdateBtn_Click(Object sender, EventArgs e) {

        // Create an instance of the HtmlTextDB component
        ASPNetPortal.HtmlTextDB text = new ASPNetPortal.HtmlTextDB();
        
        // Update the text within the HtmlText table
        text.UpdateHtmlText(moduleId, Server.HtmlEncode(DesktopText.Text), Server.HtmlEncode(MobileSummary.Text), Server.HtmlEncode(MobileDetails.Text));

        // Redirect back to the portal home page
        Response.Redirect((String) ViewState["UrlReferrer"]);
    }

    //****************************************************************
    //
    // The CancelBtn_Click event handler on this Page is used to cancel
    // out of the page, and return the user back to the portal home
    // page.
    //
    //****************************************************************

    void CancelBtn_Click(Object sender, EventArgs e) {

        // Redirect back to the portal home page
        Response.Redirect((String) ViewState["UrlReferrer"]);
    }

</script>
<html>
    <head>
        <meta name="vs_showGrid" content="True">
        <link rel="stylesheet" href="../Portal.css" type="text/css">
    </head>
    <body leftmargin="0" bottommargin="0" rightmargin="0" topmargin="0" marginheight="0" marginwidth="0">
        <form runat="server">
            <table width="100%" cellspacing="0" cellpadding="0" border="0">
                <tr valign="top">
                    <td colspan="2">
                        <portal:Banner id="SiteHeader" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <br>
                        <table width="98%" cellspacing="0" cellpadding="4" border="0">
                            <tr valign="top">
                                <td width="100">
                                    &nbsp;
                                </td>
                                <td width="*">
                                    <table width="750" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td align="left" class="Head">
                                                Html Settings
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <hr noshade size="1">
                                            </td>
                                        </tr>
                                    </table>
                                    <table width="720" cellspacing="0" cellpadding="0">
                                        <tr valign="top">
                                            <td class="SubHead">
                                                Desktop Html Content:
                                            </td>
                                            <td>
                                                &nbsp;&nbsp;
                                            </td>
                                            <td>
                                                <asp:TextBox id="DesktopText" columns="75" width="650" rows="12" textmode="multiline" runat="server" />
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="SubHead">
                                                Mobile Summary (optional):
                                            </td>
                                            <td>
                                                &nbsp;&nbsp;
                                            </td>
                                            <td>
                                                <asp:TextBox id="MobileSummary" columns="75" width="650" rows="3" textmode="multiline" runat="server" />
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="SubHead">
                                                Mobile Details (optional):
                                            </td>
                                            <td>
                                                &nbsp;&nbsp;
                                            </td>
                                            <td>
                                                <asp:TextBox id="MobileDetails" columns="75" width="650" rows="5" textmode="multiline" runat="server" />
                                            </td>
                                        </tr>
                                    </table>
                                    <p>
                                        <asp:LinkButton id="updateButton" Text="Update" runat="server" class="CommandButton" BorderStyle="none" OnClick="UpdateBtn_Click" />
                                        &nbsp;
                                        <asp:LinkButton id="cancelButton" Text="Cancel" CausesValidation="False" runat="server" class="CommandButton" BorderStyle="none" OnClick="CancelBtn_Click" />
                                        &nbsp;
                                    </p>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>

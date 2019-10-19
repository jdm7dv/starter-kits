<%@ Page Language="C#" %>
<%@ Register TagPrefix="portal" TagName="Banner" Src="~/DesktopPortalBanner.ascx" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="ASPNetPortal" %>
<script runat="server">

    int itemId = 0;
    int moduleId = 0;

    //****************************************************************
    //
    // The Page_Load event on this Page is used to obtain the 
    // ItemId of the link to edit.
    //
    // It then uses the ASPNetPortal.LinkDB() data component
    // to populate the page's edit controls with the links details.
    //
    //****************************************************************

    void Page_Load(Object Sender, EventArgs e) {

        // Determine ModuleId of Links Portal Module
        moduleId = Int32.Parse(Request.Params["Mid"]);

        // Verify that the current user has access to edit this module
        if (PortalSecurity.HasEditPermissions(moduleId) == false) {
            Response.Redirect("~/Admin/EditAccessDenied.aspx");
        }

        // Determine ItemId of Link to Update
        if (Request.Params["ItemId"] != null) {
            itemId = Int32.Parse(Request.Params["ItemId"]);
        }

        // If the page is being requested the first time, determine if an
        // link itemId value is specified, and if so populate page
        // contents with the link details

        if (Page.IsPostBack == false) {

            if (itemId != 0) {

                // Obtain a single row of link information
                ASPNetPortal.LinkDB links = new ASPNetPortal.LinkDB();
                SqlDataReader dr = links.GetSingleLink(itemId);
                
                // Read in first row from database
                dr.Read();

                TitleField.Text = (String) dr["Title"];
                DescriptionField.Text = (String) dr["Description"];
                UrlField.Text = (String) dr["Url"];
                MobileUrlField.Text = (String) dr["MobileUrl"];
                ViewOrderField.Text = dr["ViewOrder"].ToString();
                CreatedBy.Text = (String) dr["CreatedByUser"];
                CreatedDate.Text = ((DateTime) dr["CreatedDate"]).ToShortDateString();
                
                // Close datareader
                dr.Close();
            }

            // Store URL Referrer to return to portal
            ViewState["UrlReferrer"] = Request.UrlReferrer.ToString();
        }
    }

    //****************************************************************
    //
    // The UpdateBtn_Click event handler on this Page is used to either
    // create or update a link.  It  uses the ASPNetPortal.LinkDB()
    // data component to encapsulate all data functionality.
    //
    //****************************************************************

    void UpdateBtn_Click(Object sender, EventArgs e) {

        if (Page.IsValid == true) {

            // Create an instance of the Link DB component
            ASPNetPortal.LinkDB links = new ASPNetPortal.LinkDB();

            if (itemId == 0) {

                // Add the link within the Links table
                links.AddLink( moduleId, itemId, Context.User.Identity.Name, TitleField.Text, UrlField.Text, MobileUrlField.Text, Int32.Parse(ViewOrderField.Text), DescriptionField.Text );
            }
            else {

                // Update the link within the Links table
                links.UpdateLink( moduleId, itemId, Context.User.Identity.Name, TitleField.Text, UrlField.Text, MobileUrlField.Text, Int32.Parse(ViewOrderField.Text), DescriptionField.Text );
            }

            // Redirect back to the portal home page
            Response.Redirect((String) ViewState["UrlReferrer"]);
        }
    }

    //****************************************************************
    //
    // The DeleteBtn_Click event handler on this Page is used to delete 
    // a link.  It  uses the ASPNetPortal.LinksDB()
    // data component to encapsulate all data functionality.
    //
    //****************************************************************

    void DeleteBtn_Click(Object sender, EventArgs e) {

        // Only attempt to delete the item if it is an existing item
        // (new items will have "ItemId" of 0)

        if (itemId != 0) {

            ASPNetPortal.LinkDB links = new ASPNetPortal.LinkDB();
            links.DeleteLink(itemId);
        }

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
        <link rel="stylesheet" href='<%= Request.ApplicationPath + "/Portal.css" %>' type="text/css" />
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
                                <td width="150">
                                    &nbsp;
                                </td>
                                <td width="*">
                                    <table width="500" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td align="left" class="Head">
                                                Link Details
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <hr noshade size="1pt">
                                            </td>
                                        </tr>
                                    </table>
                                    <table width="750" cellspacing="0" cellpadding="0" border="0">
                                        <tr>
                                            <td width="100" class="SubHead">
                                                Title:
                                            </td>
                                            <td rowspan="5">
                                                &nbsp;
                                            </td>
                                            <td>
                                                <asp:TextBox id="TitleField" CssClass="NormalTextBox" width="390" Columns="30" maxlength="150" runat="server" />
                                            </td>
                                            <td width="25" rowspan="5">
                                                &nbsp;
                                            </td>
                                            <td class="Normal" width="250">
                                                <asp:RequiredFieldValidator id="Req1" Display="Static" ErrorMessage="You Must Enter a Valid Title" ControlToValidate="TitleField" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="SubHead">
                                                Url:
                                            </td>
                                            <td>
                                                <asp:TextBox id="UrlField" CssClass="NormalTextBox" width="390" Columns="30" maxlength="150" runat="server" />
                                            </td>
                                            <td class="Normal">
                                                <asp:RequiredFieldValidator id="Req2" Display="Static" runat="server" ErrorMessage="You Must Enter a Valid URL" ControlToValidate="UrlField" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="SubHead">
                                                Mobile Url:
                                            </td>
                                            <td>
                                                <asp:TextBox id="MobileUrlField" CssClass="NormalTextBox" width="390" Columns="30" maxlength="150" runat="server" />
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="SubHead">
                                                Description:
                                            </td>
                                            <td>
                                                <asp:TextBox id="DescriptionField" CssClass="NormalTextBox" width="390" Columns="30" maxlength="150" runat="server" />
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="SubHead">
                                                View Order:
                                            </td>
                                            <td>
                                                <asp:TextBox id="ViewOrderField" CssClass="NormalTextBox" width="390" Columns="30" maxlength="3" runat="server" />
                                            </td>
                                            <td class="Normal">
                                                <asp:RequiredFieldValidator Display="Static" id="RequiredViewOrder" runat="server" ControlToValidate="ViewOrderField" ErrorMessage="You Must Enter a Valid View Order" />
                                                <asp:CompareValidator Display="Static" id="VerifyViewOrder" runat="server" Operator="DataTypeCheck" ControlToValidate="ViewOrderField" Type="Integer" ErrorMessage="You Must Enter a Valid View Order" />
                                            </td>
                                        </tr>
                                    </table>
                                    <p>
                                        <asp:LinkButton id="updateButton" Text="Update" runat="server" CssClass="CommandButton" BorderStyle="none" OnClick="UpdateBtn_Click" />
                                        &nbsp;
                                        <asp:LinkButton id="cancelButton" Text="Cancel" CausesValidation="False" runat="server" CssClass="CommandButton" BorderStyle="none" OnClick="CancelBtn_Click" />
                                        &nbsp;
                                        <asp:LinkButton id="deleteButton" Text="Delete this item" CausesValidation="False" runat="server" CssClass="CommandButton" BorderStyle="none" OnClick="DeleteBtn_Click" />
                                        <hr noshade size="1pt" width="500">
                                        <span class="Normal">Created by
                                            <asp:label id="CreatedBy" runat="server" />
                                            on
                                            <asp:label id="CreatedDate" runat="server" />
                                            <br>
                                        </span>
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

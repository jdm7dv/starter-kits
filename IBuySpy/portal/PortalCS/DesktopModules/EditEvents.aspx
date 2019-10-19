<%@ Page Language="C#" %>
<%@ Register TagPrefix="portal" TagName="Banner" Src="~/DesktopPortalBanner.ascx" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="ASPNetPortal" %>
<script runat="server">

    int itemId = 0;
    int moduleId = 0;

    //****************************************************************
    //
    // The Page_Load event on this Page is used to obtain the ModuleId
    // and ItemId of the event to edit.
    //
    // It then uses the ASPNetPortal.EventsDB() data component
    // to populate the page's edit controls with the event details.
    //
    //****************************************************************

    void Page_Load(Object Sender, EventArgs e) {

        // Determine ModuleId of Events Portal Module
        moduleId = Int32.Parse(Request.Params["Mid"]);

        // Verify that the current user has access to edit this module
        if (PortalSecurity.HasEditPermissions(moduleId) == false) {
            Response.Redirect("~/Admin/EditAccessDenied.aspx");
        }

        // Determine ItemId of Events to Update
        if (Request.Params["ItemId"] != null) {
            itemId = Int32.Parse(Request.Params["ItemId"]);
        }

        // If the page is being requested the first time, determine if an
        // event itemId value is specified, and if so populate page
        // contents with the event details

        if (Page.IsPostBack == false) {

            if (itemId != 0) {

                // Obtain a single row of event information
                ASPNetPortal.EventsDB events = new ASPNetPortal.EventsDB();
                SqlDataReader dr = events.GetSingleEvent(itemId);
                
                // Read first row from database
                dr.Read();

                TitleField.Text = (String) dr["Title"];
                DescriptionField.Text = (String) dr["Description"];
                ExpireField.Text = ((DateTime) dr["ExpireDate"]).ToShortDateString();
                CreatedBy.Text = (String) dr["CreatedByUser"];
                WhereWhenField.Text = (String) dr["WhereWhen"];
                CreatedDate.Text = ((DateTime) dr["CreatedDate"]).ToShortDateString();
                
                dr.Close();
            }

            // Store URL Referrer to return to portal
            ViewState["UrlReferrer"] = Request.UrlReferrer.ToString();
        }
    }

    //****************************************************************
    //
    // The UpdateBtn_Click event handler on this Page is used to either
    // create or update an event.  It uses the ASPNetPortal.EventsDB()
    // data component to encapsulate all data functionality.
    //
    //****************************************************************

    void UpdateBtn_Click(Object sender, EventArgs e) {

        // Only Update if the Entered Data is Valid
        if (Page.IsValid == true) {

            // Create an instance of the Event DB component
            ASPNetPortal.EventsDB events = new ASPNetPortal.EventsDB();

            if (itemId == 0) {

                // Add the event within the Events table
                events.AddEvent( moduleId, itemId, Context.User.Identity.Name, TitleField.Text, DateTime.Parse(ExpireField.Text), DescriptionField.Text, WhereWhenField.Text );
            }
            else {

                // Update the event within the Events table
                events.UpdateEvent( moduleId, itemId, Context.User.Identity.Name, TitleField.Text, DateTime.Parse(ExpireField.Text), DescriptionField.Text, WhereWhenField.Text );
            }

            // Redirect back to the portal home page
            Response.Redirect((String) ViewState["UrlReferrer"]);
        }
    }

    //****************************************************************
    //
    // The DeleteBtn_Click event handler on this Page is used to delete an
    // an event.  It  uses the ASPNetPortal.EventsDB() data component to
    // encapsulate all data functionality.
    //
    //****************************************************************

    void DeleteBtn_Click(Object sender, EventArgs e) {

        // Only attempt to delete the item if it is an existing item
        // (new items will have "ItemId" of 0)

        if (itemId != 0) {

            ASPNetPortal.EventsDB events = new ASPNetPortal.EventsDB();
            events.DeleteEvent(itemId);
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
                                <td width="100">
                                    &nbsp;
                                </td>
                                <td width="*">
                                    <table width="500" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td align="left" class="Head">
                                                Event Details
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <hr noshade size="1pt">
                                            </td>
                                        </tr>
                                    </table>
                                    <table width="750" cellspacing="0" cellpadding="0">
                                        <tr valign="top">
                                            <td width="100" class="SubHead">
                                                Title:
                                            </td>
                                            <td rowspan="4">
                                                &nbsp;
                                            </td>
                                            <td>
                                                <asp:TextBox id="TitleField" cssclass="NormalTextBox" width="390" Columns="30" maxlength="150" runat="server" />
                                            </td>
                                            <td width="25" rowspan="4">
                                                &nbsp;
                                            </td>
                                            <td class="Normal" width="250">
                                                <asp:RequiredFieldValidator Display="Static" runat="server" ErrorMessage="You Must Enter a Valid Title" ControlToValidate="TitleField" />
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="SubHead">
                                                Description:
                                            </td>
                                            <td>
                                                <asp:TextBox id="DescriptionField" TextMode="Multiline" width="390" Columns="44" Rows="6" runat="server" />
                                            </td>
                                            <td class="Normal">
                                                <asp:RequiredFieldValidator Display="Static" runat="server" ErrorMessage="You Must Enter a Valid Description" ControlToValidate="DescriptionField" />
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="SubHead">
                                                Where/When:
                                            </td>
                                            <td>
                                                <asp:TextBox id="WhereWhenField" cssclass="NormalTextBox" width="390" Columns="30" maxlength="150" runat="server" />
                                            </td>
                                            <td class="Normal">
                                                <asp:RequiredFieldValidator Display="Static" runat="server" ErrorMessage="You Must Enter a Valid Time/Location" ControlToValidate="WhereWhenField" />
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="SubHead">
                                                Expires:
                                            </td>
                                            <td>
                                                <asp:TextBox id="ExpireField" Text="12/31/2001" cssclass="NormalTextBox" width="100" Columns="8" runat="server" />
                                            </td>
                                            <td class="Normal">
                                                <asp:RequiredFieldValidator Display="Static" id="RequiredExpireDate" runat="server" ErrorMessage="You Must Enter a Valid Expiration Date" ControlToValidate="ExpireField" />
                                                <asp:CompareValidator Display="Static" id="VerifyExpireDate" runat="server" Operator="DataTypeCheck" ControlToValidate="ExpireField" Type="Date" ErrorMessage="You Must Enter a Valid Expiration Date" />
                                            </td>
                                        </tr>
                                    </table>
                                    <p>
                                        <asp:LinkButton id="updateButton" Text="Update" runat="server" class="CommandButton" BorderStyle="none" OnClick="UpdateBtn_Click" />
                                        &nbsp;
                                        <asp:LinkButton id="cancelButton" Text="Cancel" CausesValidation="False" runat="server" class="CommandButton" BorderStyle="none" OnClick="CancelBtn_Click" />
                                        &nbsp;
                                        <asp:LinkButton id="deleteButton" Text="Delete this item" CausesValidation="False" runat="server" class="CommandButton" BorderStyle="none" OnClick="DeleteBtn_Click" />
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

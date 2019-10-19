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
    // and ItemId of the contact to edit.
    //
    // It then uses the ASPNetPortal.ContactsDB() data component
    // to populate the page's edit controls with the contact details.
    //
    //****************************************************************

    void Page_Load(Object Sender, EventArgs e) {

        // Determine ModuleId of Contacts Portal Module
        moduleId = Int32.Parse(Request.Params["Mid"]);

        // Verify that the current user has access to edit this module
        if (PortalSecurity.HasEditPermissions(moduleId) == false) {
            Response.Redirect("~/Admin/EditAccessDenied.aspx");
        }

        // Determine ItemId of Contacts to Update
        if (Request.Params["ItemId"] != null) {
            itemId = Int32.Parse(Request.Params["ItemId"]);
        }

        // If the page is being requested the first time, determine if an
        // contact itemId value is specified, and if so populate page
        // contents with the contact details

        if (Page.IsPostBack == false) {

            if (itemId != 0) {

                // Obtain a single row of contact information
                ASPNetPortal.ContactsDB contacts = new ASPNetPortal.ContactsDB();
                SqlDataReader dr = contacts.GetSingleContact(itemId);
                
                // Read first row from database
                dr.Read();

                NameField.Text = (String) dr["Name"];
                RoleField.Text = (String) dr["Role"];
                EmailField.Text = (String) dr["Email"];
                Contact1Field.Text = (String) dr["Contact1"];
                Contact2Field.Text = (String) dr["Contact2"];
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
    // create or update a contact.  It  uses the ASPNetPortal.ContactsDB()
    // data component to encapsulate all data functionality.
    //
    //****************************************************************

    void UpdateBtn_Click(Object sender, EventArgs e) {

        // Only Update if Entered data is Valid
        if (Page.IsValid == true) {

            // Create an instance of the ContactsDB component
            ASPNetPortal.ContactsDB contacts = new ASPNetPortal.ContactsDB();

            if (itemId == 0) {

                // Add the contact within the contacts table
                contacts.AddContact( moduleId, itemId, Context.User.Identity.Name, NameField.Text, RoleField.Text, EmailField.Text, Contact1Field.Text, Contact2Field.Text );
            }
            else {

                // Update the contact within the contacts table
                contacts.UpdateContact( moduleId, itemId, Context.User.Identity.Name, NameField.Text, RoleField.Text, EmailField.Text, Contact1Field.Text, Contact2Field.Text );
            }

            // Redirect back to the portal home page
            Response.Redirect((String) ViewState["UrlReferrer"]);
        }
    }

    //****************************************************************
    //
    // The DeleteBtn_Click event handler on this Page is used to delete an
    // a contact.  It  uses the ASPNetPortal.ContactsDB()
    // data component to encapsulate all data functionality.
    //
    //****************************************************************

    void DeleteBtn_Click(Object sender, EventArgs e) {

        // Only attempt to delete the item if it is an existing item
        // (new items will have "ItemId" of 0)

        if (itemId != 0) {

            ASPNetPortal.ContactsDB contacts = new ASPNetPortal.ContactsDB();
            contacts.DeleteContact(itemId);
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
                                <td>
                                    <table width="500" cellspacing="0" cellpadding="0" border="0">
                                        <tr>
                                            <td align="left" class="Head">
                                                Contact Details
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <hr noshade size="1pt">
                                            </td>
                                        </tr>
                                    </table>
                                    <table width="750" cellspacing="0" cellpadding="0" border="0">
                                        <tr valign="top">
                                            <td width="100" class="SubHead">
                                                Name:
                                            </td>
                                            <td rowspan="5">
                                                &nbsp;
                                            </td>
                                            <td align="left">
                                                <asp:TextBox id="NameField" cssclass="NormalTextBox" width="390" Columns="30" maxlength="50" runat="server" />
                                            </td>
                                            <td width="25" rowspan="5">
                                                &nbsp;
                                            </td>
                                            <td class="Normal" width="250">
                                                <asp:RequiredFieldValidator Display="Static" runat="server" ErrorMessage="You Must Enter a Valid Name" ControlToValidate="NameField" />
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="SubHead">
                                                Role:
                                            </td>
                                            <td>
                                                <asp:TextBox id="RoleField" cssclass="NormalTextBox" width="390" Columns="30" maxlength="100" runat="server" />
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="SubHead">
                                                Email:
                                            </td>
                                            <td>
                                                <asp:TextBox id="EmailField" cssclass="NormalTextBox" width="390" Columns="30" maxlength="100" runat="server" />
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="SubHead">
                                                Contact1:
                                            </td>
                                            <td>
                                                <asp:TextBox id="Contact1Field" cssclass="NormalTextBox" width="390" Columns="30" maxlength="250" runat="server" />
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="SubHead">
                                                Contact2:
                                            </td>
                                            <td>
                                                <asp:TextBox id="Contact2Field" cssclass="NormalTextBox" width="390" Columns="30" maxlength="250" runat="server" />
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

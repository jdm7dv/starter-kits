<%@ Control language="C#" Inherits="ASPNetPortal.PortalModuleControl" %>
<%@ Register TagPrefix="Portal" TagName="Title" Src="~/DesktopModuleTitle.ascx"%>
<script runat="server">

    //*******************************************************
    //
    // The Page_Load event handler on this User Control is used to
    // obtain a DataReader of contact information from the Contacts
    // table, and then databind the results to a DataGrid
    // server control.  It uses the ASPNetPortal.ContactsDB()
    // data component to encapsulate all data functionality.
    //
    //*******************************************************

    void Page_Load(Object sender, EventArgs e) {

        // Obtain contact information from Contacts table
        // and bind to the DataGrid Control
        ASPNetPortal.ContactsDB contacts = new ASPNetPortal.ContactsDB();

        myDataGrid.DataSource = contacts.GetContacts(ModuleId);
        myDataGrid.DataBind();
    }

</script>
<portal:title EditText="Add New Contact" EditUrl="~/DesktopModules/EditContacts.aspx" runat="server" />
<asp:datagrid id="myDataGrid" Border="0" width="100%" AutoGenerateColumns="false" EnableViewState="false" runat="server">
    <Columns>
        <asp:TemplateColumn>
            <ItemTemplate>
                <asp:HyperLink ImageUrl="~/images/edit.gif" NavigateUrl='<%# "~/DesktopModules/EditContacts.aspx?ItemID=" + DataBinder.Eval(Container.DataItem,"ItemID") + "&mid=" + ModuleId %>' Visible="<%# IsEditable %>" runat="server" />
            </ItemTemplate>
        </asp:TemplateColumn>
        <asp:BoundColumn HeaderText="Name" DataField="Name" ItemStyle-CssClass="Normal" HeaderStyle-Cssclass="NormalBold" />
        <asp:BoundColumn HeaderText="Role" DataField="Role" ItemStyle-CssClass="Normal" HeaderStyle-Cssclass="NormalBold" />
        <asp:HyperLinkColumn HeaderText="Email" DataTextField="Email" DataNavigateUrlField="Email" DataNavigateUrlFormatString="mailto:{0}" ItemStyle-CssClass="Normal" HeaderStyle-Cssclass="NormalBold" />
        <asp:BoundColumn HeaderText="Contact 1" DataField="Contact1" ItemStyle-CssClass="Normal" HeaderStyle-Cssclass="NormalBold" />
        <asp:BoundColumn HeaderText="Contact 2" DataField="Contact2" ItemStyle-CssClass="Normal" HeaderStyle-Cssclass="NormalBold" />
    </Columns>
</asp:datagrid>

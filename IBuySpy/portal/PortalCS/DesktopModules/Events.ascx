<%@ Control language="C#" Inherits="ASPNetPortal.PortalModuleControl" %>
<%@ Register TagPrefix="Portal" TagName="Title" Src="~/DesktopModuleTitle.ascx"%>
<script runat="server">

    //*******************************************************
    //
    // The Page_Load event handler on this User Control is used to
    // obtain a DataReader of event information from the Events
    // table, and then databind the results to a templated DataList
    // server control.  It uses the ASPNetPortal.EventDB()
    // data component to encapsulate all data functionality.
    //
    //*******************************************************

    void Page_Load(Object sender, EventArgs e) {

        // Obtain the list of events from the Events table
        // and bind to the DataList Control
        ASPNetPortal.EventsDB events = new ASPNetPortal.EventsDB();

        myDataList.DataSource = events.GetEvents(ModuleId);
        myDataList.DataBind();
    }

</script>
<portal:title EditText="Add New Event" EditUrl="~/DesktopModules/EditEvents.aspx" runat="server" />
<asp:DataList id="myDataList" CellPadding="4" Width="98%" EnableViewState="false" runat="server">
    <ItemTemplate>
        <span class="ItemTitle">
            <asp:HyperLink id="editLink" ImageUrl="~/images/edit.gif" NavigateUrl='<%# "~/DesktopModules/EditEvents.aspx?ItemID=" + DataBinder.Eval(Container.DataItem,"ItemID") + "&mid=" + ModuleId %>' Visible="<%# IsEditable %>" runat="server" />
            <asp:Label Text='<%# DataBinder.Eval(Container.DataItem,"Title") %>' runat="server" />
        </span>
        <br>
        <span class="Normal"><i>
                <%# DataBinder.Eval(Container.DataItem,"WhereWhen") %>
            </i></span>
        <br>
        <span class="Normal">
            <%# DataBinder.Eval(Container.DataItem,"Description") %>
        </span>
        <br>
    </ItemTemplate>
</asp:DataList>

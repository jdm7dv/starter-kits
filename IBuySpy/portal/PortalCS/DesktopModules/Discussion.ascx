<%@ Control language="C#" Inherits="ASPNetPortal.PortalModuleControl" %>
<%@ Register TagPrefix="Portal" TagName="Title" Src="~/DesktopModuleTitle.ascx"%>
<%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">

    //*******************************************************
    //
    // The Page_Load server event handler on this User Control is used
    // on the first visit of the page to obtain and databind a list of
    // discussion messages.
    //
    //*******************************************************

    void Page_Load(Object Sender, EventArgs e) {

        if (Page.IsPostBack == false) {
            BindList();
        }
    }

    //*******************************************************
    //
    // The BindList method obtains the list of top-level messages
    // from the Discussion table and then databinds them against
    // the "TopLevelList" asp:datalist server control.  It uses 
    // the ASPNetPortal.DiscussionDB() data component to encapsulate 
    // all data access functionality.
    //
    //*******************************************************

    void BindList() {

        // Obtain a list of discussion messages for the module
        // and bind to datalist
        ASPNetPortal.DiscussionDB discuss = new ASPNetPortal.DiscussionDB();

        TopLevelList.DataSource = discuss.GetTopLevelMessages(ModuleId);
        TopLevelList.DataBind();
    }

    //*******************************************************
    //
    // The GetThreadMessages method is used to obtain the list
    // of messages contained within a sub-topic of the
    // a top-level discussion message thread.  This method is
    // used to populate the "DetailList" asp:datalist server control
    // in the SelectedItemTemplate of "TopLevelList".
    //
    //*******************************************************

    SqlDataReader GetThreadMessages() {

        // Obtain a list of discussion messages for the module
        ASPNetPortal.DiscussionDB discuss = new ASPNetPortal.DiscussionDB();
        SqlDataReader dr = discuss.GetThreadMessages(TopLevelList.DataKeys[TopLevelList.SelectedIndex].ToString());

        // Return the filtered DataView
        return dr;
    }

    //*******************************************************
    //
    // The TopLevelList_Select server event handler is used to
    // expand/collapse a selected discussion topic within the 
    // hierarchical <asp:DataList> server control.
    //
    //*******************************************************

    void TopLevelList_Select(object Sender, DataListCommandEventArgs e) {

        // Determine the command of the button (either "select" or "collapse")
        String command = ((ImageButton)e.CommandSource).CommandName;

        // Update asp:datalist selection index depending upon the type of command
        // and then rebind the asp:datalist with content

        if (command == "collapse") {
            TopLevelList.SelectedIndex = -1;
        }
        else {
            TopLevelList.SelectedIndex = e.Item.ItemIndex;
        }

        BindList();
    }

    //*******************************************************
    //
    // The FormatUrl method is a helper messages called by a
    // databinding statement within the <asp:DataList> server
    // control template.  It is defined as a helper method here
    // (as opposed to inline within the template) to to improve 
    // code organization and avoid embedding logic within the 
    // content template.
    //
    //*******************************************************

    String FormatUrl(int item) {

        return "~/DesktopModules/DiscussDetails.aspx?ItemID=" + item + "&mid=" + ModuleId;
    }

    //*******************************************************
    //
    // The NodeImage method is a helper method called by a
    // databinding statement within the <asp:datalist> server
    // control template.  It controls whether or not an item
    // in the list should be rendered as an expandable topic
    // or just as a single node within the list.
    //
    //*******************************************************

    String NodeImage(int count) {

        if (count > 0) {
            return "~/images/plus.gif";
        }
        else {
            return "~/images/node.gif";
        }
    }

</script>
<portal:title EditText="Add New Thread" EditUrl="~/DesktopModules/DiscussDetails.aspx" EditTarget="_new" runat="server" />
<asp:DataList id="TopLevelList" width="98%" ItemStyle-Cssclass="Normal" DataKeyField="Parent" OnItemCommand="TopLevelList_Select" runat="server">
    <ItemTemplate>
        <asp:ImageButton id="btnSelect" ImageUrl='<%# NodeImage((int)DataBinder.Eval(Container.DataItem, "ChildCount")) %>' CommandName="select" runat="server" />
        <asp:hyperlink Text='<%# DataBinder.Eval(Container.DataItem, "Title") %>' NavigateUrl='<%# FormatUrl((int)DataBinder.Eval(Container.DataItem, "ItemID")) %>' Target="_new" runat="server" />, from
        <%# DataBinder.Eval(Container.DataItem,"CreatedByUser") %>, posted
        <%# DataBinder.Eval(Container.DataItem,"CreatedDate", "{0:g}") %>
    </ItemTemplate>
    <SelectedItemTemplate>
        <asp:ImageButton id="btnCollapse" ImageUrl="~/images/minus.gif" runat="server" CommandName="collapse" />
        <asp:hyperlink Text='<%# DataBinder.Eval(Container.DataItem, "Title") %>' NavigateUrl='<%# FormatUrl((int)DataBinder.Eval(Container.DataItem, "ItemID")) %>' Target="_new" runat="server" />, from
        <%# DataBinder.Eval(Container.DataItem,"CreatedByUser") %>, posted
        <%# DataBinder.Eval(Container.DataItem,"CreatedDate", "{0:g}") %>
        <asp:DataList id="DetailList" ItemStyle-Cssclass="Normal" datasource="<%# GetThreadMessages() %>" runat="server">
            <ItemTemplate>
                <%# DataBinder.Eval(Container.DataItem, "Indent") %>
                <img src="<%=Request.ApplicationPath%>/images/1x1.gif" height="15">
                <asp:hyperlink Text='<%# DataBinder.Eval(Container.DataItem, "Title") %>' NavigateUrl='<%# FormatUrl((int)DataBinder.Eval(Container.DataItem, "ItemID")) %>' Target="_new" runat="server" />, from
                <%# DataBinder.Eval(Container.DataItem,"CreatedByUser") %>, posted
                <%# DataBinder.Eval(Container.DataItem,"CreatedDate", "{0:g}") %>
            </ItemTemplate>
        </asp:DataList>
    </SelectedItemTemplate>
</asp:DataList>

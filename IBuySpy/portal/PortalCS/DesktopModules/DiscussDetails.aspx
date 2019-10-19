<%@ Page language="C#" %>
<%@ Register TagPrefix="portal" TagName="Banner" Src="~/DesktopPortalBanner.ascx" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="ASPNetPortal" %>
<script runat="server">

    int moduleId = 0;
    int itemId = 0;

    //*******************************************************
    //
    // The Page_Load server event handler on this page is used
    // to obtain the ModuleId and ItemId of the discussion list,
    // and to then display the message contents.
    //
    //*******************************************************

    void Page_Load(Object sender, EventArgs e) {

        // Obtain moduleId and ItemId from QueryString
        moduleId = Int32.Parse(Request.Params["Mid"]);
        
        if (Request.Params["ItemId"] != null) {
            itemId = Int32.Parse(Request.Params["ItemId"]);
        }
        else {
            itemId = 0;
            EditPanel.Visible = true;
            ButtonPanel.Visible = false;
        }

        // Populate message contents if this is the first visit to the page
        if (Page.IsPostBack == false) {
            BindData();
        }

        if (PortalSecurity.HasEditPermissions(moduleId) == false) {
        
            if (itemId == 0) {
                Response.Redirect("~/Admin/EditAccessDenied.aspx");
            }
            else {
                ReplyBtn.Visible=false;
            }
        }
    }

    //*******************************************************
    //
    // The ReplyBtn_Click server event handler on this page is used
    // to handle the scenario where a user clicks the message's
    // "Reply" button to perform a post.
    //
    //*******************************************************

    void ReplyBtn_Click(Object Sender, EventArgs e) {

        EditPanel.Visible = true;
        ButtonPanel.Visible = false;
    }

    //*******************************************************
    //
    // The UpdateBtn_Click server event handler on this page is used
    // to handle the scenario where a user clicks the "update"
    // button after entering a response to a message post.
    //
    //*******************************************************

    void UpdateBtn_Click(Object sender, EventArgs e) {

        // Create new discussion database component
        DiscussionDB discuss = new DiscussionDB();

        // Add new message (updating the "itemId" on the page)
        itemId = discuss.AddMessage(moduleId, itemId, User.Identity.Name, Server.HtmlEncode(TitleField.Text), Server.HtmlEncode(BodyField.Text));

        // Update visibility of page elements
        EditPanel.Visible = false;
        ButtonPanel.Visible = true;

        // Repopulate page contents with new message
        BindData();
    }

    //*******************************************************
    //
    // The CancelBtn_Click server event handler on this page is used
    // to handle the scenario where a user clicks the "cancel"
    // button to discard a message post and toggle out of
    // edit mode.
    //
    //*******************************************************

    void CancelBtn_Click(Object sender, EventArgs e) {

        // Update visibility of page elements
        EditPanel.Visible = false;
        ButtonPanel.Visible = true;
    }

    //*******************************************************
    //
    // The BindData method is used to obtain details of a message
    // from the Discussion table, and update the page with
    // the message content.
    //
    //*******************************************************

    void BindData() {

        // Obtain the selected item from the Discussion table
        ASPNetPortal.DiscussionDB discuss = new ASPNetPortal.DiscussionDB();
        SqlDataReader dr = discuss.GetSingleMessage(itemId);
        
        // Load first row from database
        dr.Read();

        // Update labels with message contents
        Title.Text = (String) dr["Title"];
        Body.Text = (String) dr["Body"];
        CreatedByUser.Text = (String) dr["CreatedByUser"];
        CreatedDate.Text = String.Format("{0:d}", dr["CreatedDate"]);
        TitleField.Text = ReTitle(Title.Text);

        int prevId = 0;
        int nextId = 0;

        // Update next and preview links
        object id1 = dr["PrevMessageID"];
        
        if (id1 != DBNull.Value) {
            prevId = (int) id1;
            prevItem.HRef = Request.Path + "?ItemId=" + prevId + "&mid=" + moduleId;
        }

        object id2 = dr["NextMessageID"];
        
        if (id2 != DBNull.Value) {
            nextId = (int) id2;
            nextItem.HRef = Request.Path + "?ItemId=" + nextId + "&mid=" + moduleId;
        }
        
        // close the datareader
        dr.Close();
        
        // Show/Hide Next/Prev Button depending on whether there is a next/prev message
        if (prevId <= 0) {
            prevItem.Visible = false;
        }

        if (nextId <= 0) {
            nextItem.Visible = false;
        }
    }

    //*******************************************************
    //
    // The ReTitle helper method is used to create the subject
    // line of a response post to a message.
    //
    //*******************************************************

    String ReTitle(String title) {

        if (title.Length > 0 & title.IndexOf("Re: ",0) == -1) {
            title = "Re: " + title;
        }

        return title;
    }

</script>
<html>
    <head>
        <link rel="stylesheet" href='<%= Request.ApplicationPath + "/Portal.css" %>' type="text/css" />
    </head>
    <body leftmargin="0" bottommargin="0" rightmargin="0" topmargin="0" marginheight="0" marginwidth="0">
        <form runat="server" name="form1">
            <table width="100%" cellspacing="0" cellpadding="0" border="0">
                <tr valign="top">
                    <td colspan="2">
                        <portal:Banner ShowTabs="false" runat="server" />
                    </td>
                </tr>
                <tr valign="top">
                    <td width="10%">
                        &nbsp;
                    </td>
                    <td>
                        <br>
                        <table width="600" cellspacing="0" cellpadding="0">
                            <tr>
                                <td align="left">
                                    <span class="Head">Message Detail</span>
                                </td>
                                <td align="right">
                                    <asp:Panel id="ButtonPanel" runat="server">
                                  <a id="prevItem" class="CommandButton" title="Previous Message" runat="server"><img src='<%=Request.ApplicationPath + "/images/rew.gif"  %>' border="0"></a>&nbsp;
                                  <a id="nextItem" class="CommandButton" title="Next Message" runat="server"><img src='<%=Request.ApplicationPath + "/images/fwd.gif"  %>' border="0"></a>&nbsp;
                                  <asp:LinkButton id="ReplyBtn" Text="Reply to this Message" runat="server" Cssclass="CommandButton" EnableViewState="false" onclick="ReplyBtn_Click" />
                              </asp:Panel>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <hr noshade size="1pt">
                                </td>
                            </tr>
                        </table>
                        <asp:panel id="EditPanel" Visible="false" runat="server">
                            <table width="600" cellspacing="0" cellpadding="4" border="0">
                                <tr valign="top">
                                    <td width="150" class="SubHead">
                                        Title:
                                    </td>
                                    <td rowspan="4">
                                        &nbsp;
                                    </td>
                                    <td width="*">
                                        <asp:TextBox id="TitleField" cssclass="NormalTextBox" width="500" columns="40" maxlength="100" runat="server" />
                                    </td>
                                </tr>
                                <tr valign="top">
                                    <td class="SubHead">
                                        Body:
                                    </td>
                                    <td width="*">
                                        <asp:TextBox id="BodyField" TextMode="Multiline" width="500" columns="59" Rows="15" runat="server" />
                                    </td>
                                </tr>
                                <tr valign="top">
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <asp:LinkButton id="updateButton" OnClick="UpdateBtn_Click" Text="Submit" runat="server" class="CommandButton" />
                                        &nbsp;
                                        <asp:LinkButton id="cancelButton" OnClick="CancelBtn_Click" Text="Cancel" CausesValidation="False" runat="server" class="CommandButton" />
                                        &nbsp;
                                    </td>
                                </tr>
                                <tr valign="top">
                                    <td class="SubHead">
                                        Original Message:
                                    </td>
                                    <td>
                                        &nbsp;
                                    </td>
                                </tr>
                            </table>
                        </asp:panel>
                        <table width="600" cellspacing="0" cellpadding="4" border="0">
                            <tr valign="top">
                                <td align="left" class="Message">
                                    <b>Subject: </b>
                                    <asp:Label id="Title" runat="server" />
                                    <br>
                                    <b>Author: </b>
                                    <asp:Label id="CreatedByUser" runat="server" />
                                    <br>
                                    <b>Date: </b>
                                    <asp:Label id="CreatedDate" runat="server" />
                                    <br>
                                    <br>
                                    <asp:Label id="Body" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>

<%@ Control language="C#" Inherits="ASPNetPortal.PortalModuleControl" %>
<%@ Import Namespace="ASPNetPortal" %>
<%--

   The SignIn User Control enables clients to authenticate themselves using 
   the ASP.NET Forms based authentication system.

   When a client enters their username/password within the appropriate
   textboxes and clicks the "Login" button, the LoginBtn_Click event
   handler executes on the server and attempts to validate their
   credentials against a SQL database.

   If the password check succeeds, then the LoginBtn_Click event handler
   sets the customers username in an encrypted cookieID and redirects
   back to the portal home page.

   If the password check fails, then an appropriate error message
   is displayed.

--%>
<script runat="server">

    void LoginBtn_Click(Object sender, ImageClickEventArgs e) {

        // Attempt to Validate User Credentials using UsersDB
        UsersDB accountSystem = new UsersDB();
        String userId = accountSystem.Login(email.Text, PortalSecurity.Encrypt(password.Text));

        if ((userId != null) && (userId != "")) {

            // Use security system to set the UserID within a client-side Cookie
            FormsAuthentication.SetAuthCookie(email.Text, RememberCheckbox.Checked);

            // Redirect browser back to originating page
            Response.Redirect(Request.ApplicationPath);
        }
        else {
            Message.Text = "<" + "br" + ">Login Failed!" + "<" + "br" + ">";
        }
    }

</script>
<hr noshade size="1pt" width="98%">
<span class="SubSubHead" style="height:20">Account Login</span>
<br>
<span class="Normal">Email:</span>
<br>
<asp:TextBox id="email" columns="9" width="130" cssclass="NormalTextBox" runat="server" />
<br>
<span class="Normal">Password:</span>
<br>
<asp:TextBox id="password" columns="9" width="130" textmode="password" cssclass="NormalTextBox" runat="server" />
<br>
<asp:checkbox id="RememberCheckbox" class="Normal" Text="Remember Login" runat="server" />
<table width="100%" cellspacing="0" cellpadding="4" border="0">
    <tr>
        <td>
            <asp:ImageButton id="SigninBtn" ImageUrl="~/images/signin.gif" OnClick="LoginBtn_Click" runat="server" />
            <br>
            <a href="Admin/Register.aspx"><img src="images/register.gif" border="0"></a>
            <asp:label id="Message" class="NormalRed" runat="server" />
        </td>
    </tr>
</table>
<br>

<%@page import="db.DBConnection"%>
<%@page import="sql.User"%>
<%@page import="java.util.*"%>
<%@page import="helper.MyBoolean"%>
<jsp:useBean id="dbaccess" class="db.DBAccess" scope="session" />
<jsp:useBean id="usersession" class="helper.UserSession" scope="session" />
<!doctype html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html" charset="utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Seneca | Change Settings</title>
<link rel="shortcut icon" href="http://www.cssreset.com/favicon.png" />
<!--<link href="css/style.css" rel="stylesheet" type="text/css" media="screen and (min-width:1280px)">-->
<link href="css/style.css" rel="stylesheet" type="text/css" media="all">
<link href="css/fonts.css" rel="stylesheet" type="text/css" media="all">
<script type="text/javascript" src="http://code.jquery.com/jquery-1.9.1.js"></script>
<script type="text/javascript" src="js/modernizr.custom.79639.js"></script>
<script type="text/javascript" src="js/component.js"></script>
<script type="text/javascript" src="js/componentStepper.js"></script>
<%
	String message = request.getParameter("message");
	if (message == null || message == "null") {
		message="";
	}

	String userId = usersession.getUserId();
	if (userId.equals(""))
		response.sendRedirect("index.jsp?error=Please log in");
	User user = new User(dbaccess);
	MyBoolean prof = new MyBoolean();
	HashMap<String, Integer> userSettings = new HashMap<String, Integer>();
	HashMap<String, Integer> meetingSettings = new HashMap<String, Integer>();
	userSettings = usersession.getUserSettingsMask();
	meetingSettings = usersession.getUserMeetingSettingsMask();
%>
<script type="text/javascript">		
$(document).ready(function() {
	<%if (userSettings.get("autoShareAudio") == 0) {%>
		$(".checkbox .box:eq(0)").next(".checkmark").toggle();
		$(".checkbox .box:eq(0)").attr("aria-checked", "false");
		$(".checkbox .box:eq(0)").siblings().last().prop("checked", false);
	<%}%>
	<%if (userSettings.get("autoShareWebcam") == 0) {%>
		$(".checkbox .box:eq(1)").next(".checkmark").toggle();
		$(".checkbox .box:eq(1)").attr("aria-checked", "false");
		$(".checkbox .box:eq(1)").siblings().last().prop("checked", false);
	<%}%>
	<%if (meetingSettings.get("isPrivateChatEnabled")==0){%>
		$(".checkbox .box:eq(2)").next(".checkmark").toggle();
		$(".checkbox .box:eq(2)").attr("aria-checked", "false");
		$(".checkbox .box:eq(2)").siblings().last().prop("checked", false);
	<%}%>	
	<%if (meetingSettings.get("isViewerWebcamEnabled")==0){%>
		$(".checkbox .box:eq(3)").next(".checkmark").toggle();
		$(".checkbox .box:eq(3)").attr("aria-checked", "false");
		$(".checkbox .box:eq(3)").siblings().last().prop("checked", false);
	<%}%>	
	<%if (meetingSettings.get("isMultiWhiteboard")==0){%>
		$(".checkbox .box:eq(4)").next(".checkmark").toggle();
		$(".checkbox .box:eq(4)").attr("aria-checked", "false");
		$(".checkbox .box:eq(4)").siblings().last().prop("checked", false);
	<%}%>	
	<%if (meetingSettings.get("isRecorded")==0){%>
		$(".checkbox .box:eq(5)").next(".checkmark").toggle();
		$(".checkbox .box:eq(5)").attr("aria-checked", "false");
		$(".checkbox .box:eq(5)").siblings().last().prop("checked", false);
	<%}%>
});
</script>
</head>
<body>
<div id="page">
  <jsp:include page="header.jsp"/>
  <jsp:include page="menu.jsp"/>
  <section>
    <header>
      <p><a href="calendar.jsp" tabindex="13">home</a> � settings</p>
      <h1>Settings</h1><%=message %>
    </header>
    <form action="persist_user_settings.jsp" method="get">
      <article>
        <header>
          <h2>User Settings</h2>
          <img class="expandContent" width="9" height="6" src="images/arrowDown.svg" title="Click here to collapse/expand content"/></header>
        <fieldset>
          <div class="component">
            <label for="nickname" class="label">Nickname:</label>
            <input type="text" name="nickname" id="nickname" class="input" tabindex="15" title="Nickname" value=<%=usersession.getNick() %>>
          </div>
          <div class="component">
            <div class="checkbox" title="Automatically activate microphone"> <span class="box" role="checkbox" aria-checked="true" tabindex="17" aria-labelledby="setting1"></span>
              <label class="checkmark"></label>
              <label class="text" id="setting1">Automatically activate microphone.</label>
              <input type="checkbox" name="setting1box" id="setting1box" checked="checked">
            </div>
          </div>
          <div class="component">
            <div class="checkbox" title="Automatically activate camera"> <span class="box" role="checkbox" aria-checked="true" tabindex="18" aria-labelledby="setting2"></span>
              <label class="checkmark"></label>
              <label class="text" id="setting2">Automatically activate camera.</label>
              <input type="checkbox" name="setting2box" checked="checked">
            </div>
          </div>
        </fieldset>
      </article>
      <article>
        <header>
          <h2>Default Meeting Settings</h2>
          <img class="expandContent" width="9" height="6" src="images/arrowDown.svg" title="Click here to collapse/expand content"/></header>
        <fieldset>
          <div class="component">
            <div class="checkbox" title="Allow private chat."> <span class="box" role="checkbox" aria-checked="true" tabindex="22" aria-labelledby="eventSetting1"></span>
              <label class="checkmark"></label>
              <label class="text" id="eventSetting1">Allow private chat.</label>
              <input type="checkbox" name="eventSetting1box" checked="checked">
            </div>
          </div>
          <div class="component">
            <div class="checkbox" title="Allow camera sharing"> <span class="box" role="checkbox" aria-checked="true" tabindex="23" aria-labelledby="eventSetting2"></span>
              <label class="checkmark"></label>
              <label class="text" id="eventSetting2">Allow camera sharing.</label>
              <input type="checkbox" name="eventSetting2box" checked="checked">
            </div>
          </div>
          <div class="component">
            <div class="checkbox" title="Allow public whiteboard"> <span class="box" role="checkbox" aria-checked="true" tabindex="24" aria-labelledby="eventSetting3" ></span>
              <label class="checkmark"></label>
              <label class="text" id="eventSetting3">Allow public whiteboard.</label>
              <input type="checkbox" name="eventSetting3box" checked="checked">
            </div>
          </div>
          <div class="component">
            <div class="checkbox" title="Allow event recording"> <span class="box" role="checkbox" aria-checked="true" tabindex="25" aria-labelledby="eventSetting4"></span>
              <label class="checkmark"></label>
              <label class="text" id="eventSetting4">Allow event recording.</label>
              <input type="checkbox" name="eventSetting4box" checked="checked">
            </div>
          </div>
        </fieldset>
      </article>
       <%if (!usersession.isLDAP()) {  %>
      <article>
      <header>
          <h2>Edit Password</h2>
          <img class="expandContent" width="9" height="6" src="images/arrowDown.svg" title="Click here to collapse/expand content"/></header>
        <fieldset>
    	<a href="edit_password.jsp">Change your password</a>
    	</fieldset>
    	</article>
      <%}%>
      <article>
        <h4></h4>
        <fieldset>
          <div class="buttons">
            <button type="submit" name="submit" id="save" class="button" title="Click here to save inserted data">Save</button>
            <button type="button" name="button" id="cancel"  class="button" title="Click here to cancel">Cancel</button>
          </div>
        </fieldset>
      </article>
    </form>
  </section>
  <jsp:include page="footer.jsp"/>
</div>
</body>
</html>